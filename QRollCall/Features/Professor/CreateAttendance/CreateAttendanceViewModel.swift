import Combine
import Foundation
import CoreLocation

@MainActor
final class CreateAttendanceViewModel: ObservableObject {
    @Published var turmas: [TurmaDTO] = []
    @Published var selectedTurma: TurmaDTO?
    @Published var classType: ClassType = .first
    @Published var keywordsRaw: String = ""
    @Published var durationMinutes: Int = 5
    @Published var sala: String = ""
    @Published var isLoading = false
    @Published var isStarting = false
    @Published var errorMessage: String?

    @Published var createdChamada: ChamadaCreatedDTO?

    func loadTurmas() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            turmas = try await ProfessorService.turmas()
        } catch is CancellationError {
            return

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }

    func selectTurma(_ turma: TurmaDTO) {
        selectedTurma = turma
        sala = turma.sala
        if keywordsRaw.isEmpty {
            keywordsRaw = "HTML, CSS, JavaScript, React"
        }
    }

    func startAttendance() async -> ChamadaCreatedDTO? {
        guard let turma = selectedTurma else { return nil }
        isStarting = true
        errorMessage = nil
        defer { isStarting = false }
        let keywords = keywordsRaw
            .split(whereSeparator: { ",;\n".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let coord = try? await LocationProvider.shared.requestCoordinate()
        let dto = RegisterChamadaRequestDTO(
            horarios: nil,
            turma: turma.nome,
            segundos: durationMinutes * 60,
            materiaId: turma.id,
            latitude: coord?.latitude,
            longitude: coord?.longitude,
            classType: classType.backendValue,
            sala: sala.isEmpty ? turma.sala : sala,
            keywords: keywords
        )
        do {
            let result = try await ChamadaService.create(dto)
            createdChamada = result
            return result
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Falha ao criar chamada."
            return nil
        }
    }
}

extension ClassType {
    var backendValue: String {
        switch self {
        case .first: return "PRIMEIRA"
        case .second: return "SEGUNDA"
        case .conjugated: return "CONJUGADAS"
        }
    }
}
