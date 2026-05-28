import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let accessToken: String
    let expiresIn: Int
    let username: String
    let firstName: String?
    let lastName: String?
    let email: String
    let role: String
}

struct RegisterAlunoRequestDTO: Encodable {
    let username: String
    let email: String
    let password: String
    let faceId: String?
    let raAluno: String
}
