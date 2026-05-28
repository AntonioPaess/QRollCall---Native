import Combine
import Foundation

@MainActor
final class StudentProfileViewModel: ObservableObject {
    @Published var perfil: PerfilAlunoDTO?
    @Published var stats: EstatisticasAlunoDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        async let p = AlunoService.perfil()
        async let s = AlunoService.estatisticas()
        do {
            perfil = try await p
            stats = try await s
        } catch is CancellationError {
            return

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }

    var fullName: String {
        guard let p = perfil else { return "—" }
        return "\(p.firstName) \(p.lastName)".trimmingCharacters(in: .whitespaces)
    }

    var initials: String {
        guard let p = perfil else { return "?" }
        let f = p.firstName.prefix(1)
        let l = p.lastName.prefix(1)
        return "\(f)\(l)".uppercased()
    }

    var courseInfo: String {
        guard let p = perfil else { return "" }
        let course = p.course.isEmpty ? "Sem curso" : p.course
        let semester = p.semester.isEmpty ? "" : " - \(p.semester)"
        return "\(course)\(semester)"
    }
}
