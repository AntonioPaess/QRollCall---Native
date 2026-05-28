import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case transport(Error)
    case server(status: Int, message: String?)
    case unauthorized
    case decoding(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida."
        case .transport(let err):
            return "Falha de rede: \(err.localizedDescription)"
        case .server(let status, let message):
            return message ?? "Erro do servidor (\(status))"
        case .unauthorized:
            return "Sessão expirada. Faça login novamente."
        case .decoding:
            return "Não foi possível interpretar a resposta do servidor."
        case .unknown:
            return "Erro desconhecido."
        }
    }
}
