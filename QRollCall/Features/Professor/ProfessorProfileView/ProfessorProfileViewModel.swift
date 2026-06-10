import Combine
import Foundation

@MainActor
final class ProfessorProfileViewModel: ObservableObject {
    @Published var perfil: PerfilProfessorDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            perfil = try await ProfessorService.perfil()
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
}
