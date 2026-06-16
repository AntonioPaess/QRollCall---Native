import Combine
import Foundation

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
    @Published var verificacoes: PresencaResponseDTO.Verificacoes?
    @Published var elapsedTime: TimeInterval = 0
    @Published var codeInput: String = ""

    var didConfirm: Bool { presencaStatus?.uppercased() == "PRESENTE" }

    var failureReasons: [String] {
        guard let v = verificacoes else { return [] }
        var reasons: [String] = []
        if !v.codigo { reasons.append("Código incorreto") }
        if !v.proximidade { reasons.append("Fora do alcance do professor") }
        if !v.facial { reasons.append("Face ID não validou") }
        if !v.horario { reasons.append("Fora do horário da chamada") }
        return reasons
    }

    let allWords: [String]
    let correctWords: Set<String>
    let hasGamification: Bool

    private var startTime: Date?
    private var beaconProximity: String = "unknown"
    private var beaconAccuracy: Double = -1
    private var faceIDInFlight = false
    private let ranger: BeaconRanger

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
        self.ranger = BeaconRanger()
    }

    func bootstrap() async {
        guard let beaconUuidStr = chamada.beaconUuid,
              let beaconUuid = UUID(uuidString: beaconUuidStr) else {
            // Chamada sem beacon configurado — não dá pra validar proximidade.
            phase = .error("Chamada sem beacon configurado. Peça ao professor para abrir novamente.")
            return
        }

        let major: UInt16? = chamada.beaconMajor.flatMap { UInt16(exactly: $0) }
        let minor: UInt16? = chamada.beaconMinor.flatMap { UInt16(exactly: $0) }

        let result = await ranger.scan(uuid: beaconUuid, major: major, minor: minor)

        switch result {
        case .success(let reading):
            self.beaconProximity = reading.proximity
            self.beaconAccuracy = reading.accuracy
            let ok = try? await PresencaService.verificarProximidade(
                qrcodeId: chamada.idQrcode,
                proximity: reading.proximity,
                accuracy: reading.accuracy
            )
            if ok == true {
                advancePastProximity()
            } else {
                phase = .outOfRange
            }
        case .timeout(let reading):
            self.beaconProximity = reading.proximity
            self.beaconAccuracy = reading.accuracy
            phase = .outOfRange
        case .denied:
            phase = .error("Permissão de localização negada — habilite nos Ajustes para validar proximidade.")
        case .unsupported(let msg):
            phase = .error("Bluetooth indisponível: \(msg)")
        }
    }

    private func advancePastProximity() {
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
        guard !faceIDInFlight else { return }
        faceIDInFlight = true
        defer { faceIDInFlight = false }
        let result = await FaceIDService.authenticate(reason: "Confirme sua presença em \(chamada.materiaNome)")
        let faceVerified: Bool
        switch result {
        case .success: faceVerified = true
        case .failed, .unavailable: faceVerified = false
        }
        await submit(faceVerified: faceVerified)
    }

    private func submit(faceVerified: Bool) async {
        phase = .submitting
        do {
            let dto = PresencaRequestDTO(
                qrcodeId: chamada.idQrcode,
                faceVerified: faceVerified,
                beaconProximity: beaconProximity,
                beaconAccuracy: beaconAccuracy,
                codigo: codeInput.trimmingCharacters(in: .whitespaces)
            )
            let response = try await PresencaService.registrar(dto)
            presencaStatus = response.status
            verificacoes = response.verificacoes
            if let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
            phase = .confirmed
        } catch is CancellationError {
            return
        } catch APIError.server(let status, let message) where status == 409 {
            // Backend bloqueou: chamada interrompida (heartbeat stale).
            phase = .error(message ?? "Chamada interrompida — peça ao professor para reabrir o app.")
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
