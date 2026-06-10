import Foundation

@MainActor
struct AlunoService {
    static func perfil() async throws -> PerfilAlunoDTO {
        try await APIClient.shared.request("/api/aluno/perfil")
    }

    static func proximaAula() async throws -> ProximaAulaDTO? {
        do {
            return try await APIClient.shared.request("/api/aluno/proxima-aula") as ProximaAulaDTO
        } catch APIError.decoding {
            return nil
        }
    }

    static func estatisticas() async throws -> EstatisticasAlunoDTO {
        try await APIClient.shared.request("/api/aluno/estatisticas")
    }

    static func atividadesRecentes(limit: Int = 5) async throws -> [AtividadeDTO] {
        try await APIClient.shared.request("/api/aluno/atividades-recentes",
                                           query: ["limit": String(limit)])
    }

    static func historico(filtro: String = "todas") async throws -> HistoricoDTO {
        try await APIClient.shared.request("/api/aluno/historico",
                                           query: ["filtro": filtro])
    }

    static func chamadasAtivas() async throws -> [ChamadaAtivaDTO] {
        try await APIClient.shared.request("/api/aluno/chamadas-ativas")
    }

    static func atualizarPerfil(_ dto: UpdatePerfilAlunoDTO) async throws -> PerfilAlunoDTO {
        try await APIClient.shared.request("/api/aluno/perfil",
                                           method: .patch,
                                           body: dto)
    }
}
