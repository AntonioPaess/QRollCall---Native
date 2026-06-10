import Combine
import Foundation

@MainActor
final class ClassesViewModel: ObservableObject {
    @Published var turmas: [TurmaDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
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
}

@MainActor
final class ClassDetailViewModel: ObservableObject {
    @Published var detalhe: TurmaDetalheDTO?
    @Published var historico: [ChamadaPassadaDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(turmaId: Int64) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        async let det = ProfessorService.turma(turmaId)
        async let hist = ProfessorService.historicoDaTurma(turmaId)
        do {
            detalhe = try await det
            historico = try await hist
        } catch is CancellationError {
            return

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }

    var atRisk: [AlunoTurmaDTO] {
        detalhe?.alunos.filter { $0.atRisk } ?? []
    }

    var alunos: [AlunoTurmaDTO] {
        detalhe?.alunos ?? []
    }
}
