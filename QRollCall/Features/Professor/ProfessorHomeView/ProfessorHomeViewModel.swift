import Combine
import Foundation

@MainActor
final class ProfessorHomeViewModel: ObservableObject {
    @Published var perfil: PerfilProfessorDTO?
    @Published var nextClass: ProximaAulaProfessorDTO?
    @Published var stats: EstatisticasProfessorDTO?
    @Published var pastAttendances: [ChamadaPassadaDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        async let p = ProfessorService.perfil()
        async let n = ProfessorService.proximaAula()
        async let s = ProfessorService.estatisticas()
        async let h = ProfessorService.historico()
        do {
            perfil = try await p
            nextClass = try await n
            stats = try await s
            pastAttendances = try await h
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }
}
