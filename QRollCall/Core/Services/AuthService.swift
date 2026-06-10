import Foundation

@MainActor
struct AuthService {
    static func login(email: String, password: String) async throws -> LoginResponseDTO {
        let body = LoginRequestDTO(email: email, password: password)
        return try await APIClient.shared.request("/api/auth/login",
                                                  method: .post,
                                                  body: body,
                                                  authenticated: false)
    }

    static func registerAluno(_ dto: RegisterAlunoRequestDTO) async throws {
        _ = try await APIClient.shared.send("/api/auth/aluno/register",
                                            method: .post,
                                            body: dto,
                                            authenticated: false)
    }
}
