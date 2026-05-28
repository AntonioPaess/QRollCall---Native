import Combine
import Foundation
import CoreLocation

@MainActor
final class AttendanceFlowViewModel: ObservableObject {
    enum Phase: Equatable {
        case loadingChamada
        case outOfRange
        case gamification
        case gamificationFail
        case codeEntry
        case faceID
        case submitting
        case confirmed
        case error(String)
    }

    @Published var phase: Phase = .loadingChamada
    @Published var chamada: ChamadaAtivaDTO
    @Published var presencaStatus: String?
    @Published var elapsedTime: TimeInterval = 0
    @Published var codeInput: String = ""

    let allWords: [String]
    let correctWords: Set<String>
    let hasGamification: Bool

    private var startTime: Date?
    private var coordinate: CLLocationCoordinate2D?

    init(chamada: ChamadaAtivaDTO) {
        self.chamada = chamada
        let real = chamada.keywords?.filter { !$0.isEmpty } ?? []
        if real.isEmpty {
            self.hasGamification = false
            self.correctWords = []
            self.allWords = []
        } else {
            self.hasGamification = true
            self.correctWords = Set(real)
            let distractors = AttendanceFlowViewModel.randomDistractors(excluding: real, count: max(real.count, 4))
            self.allWords = (real + distractors).shuffled()
        }
    }

    func bootstrap() async {
        do {
            let coord = try await LocationProvider.shared.requestCoordinate()
            self.coordinate = coord
            let ok = try await PresencaService.verificarLocalizacao(
                qrcodeId: chamada.idQrcode,
                latitude: coord.latitude,
                longitude: coord.longitude
            )
            if !ok {
                phase = .outOfRange
                return
            }
            advancePastLocation()
        } catch {
            // sem permissão / falha — segue com (0,0) para o backend decidir
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            advancePastLocation()
        }
    }

    private func advancePastLocation() {
        startTime = Date()
        phase = hasGamification ? .gamification : .codeEntry
    }

    func retryRange() {
        phase = .loadingChamada
        Task { await bootstrap() }
    }

    func gamificationSucceeded() {
        phase = .codeEntry
    }

    func gamificationFailed() {
        phase = .gamificationFail
    }

    func retryGamification() {
        phase = .gamification
    }

    func confirmCodeAndProceedToFace() {
        guard !codeInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        phase = .faceID
    }

    func runFaceIDAndSubmit() async {
        let result = await FaceIDService.authenticate(reason: "Confirme sua presença em \(chamada.materiaNome)")
        let faceVerified: Bool
        switch result {
        case .success: faceVerified = true
        case .failed, .unavailable: faceVerified = false
        }
        await submit(faceVerified: faceVerified)
    }

    private func submit(faceVerified: Bool) async {
        let coord = coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        phase = .submitting
        do {
            let dto = PresencaRequestDTO(
                qrcodeId: chamada.idQrcode,
                faceVerified: faceVerified,
                latitude: coord.latitude,
                longitude: coord.longitude,
                codigo: codeInput.trimmingCharacters(in: .whitespaces)
            )
            let response = try await PresencaService.registrar(dto)
            presencaStatus = response.status
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
            phase = .confirmed
        } catch is CancellationError {
            return
        } catch {
            phase = .error((error as? LocalizedError)?.errorDescription ?? "Falha ao registrar presença.")
        }
    }

    private static func randomDistractors(excluding correct: [String], count: Int) -> [String] {
        let pool = ["FUTEBOL", "RECEITA", "CINEMA", "PRAIA", "MÚSICA", "VIAGEM",
                    "JOGO", "NOVELA", "PIZZA", "SÉRIE", "CARRO", "LIVRO",
                    "FESTA", "CAFÉ", "MAR", "MONTANHA"]
        let correctSet = Set(correct.map { $0.uppercased() })
        return pool.filter { !correctSet.contains($0.uppercased()) }
                   .shuffled()
                   .prefix(count)
                   .map { $0 }
    }
}
