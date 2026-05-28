import Foundation

@MainActor
struct ProfessorService {
    static func perfil() async throws -> PerfilProfessorDTO {
        try await APIClient.shared.request("/api/professor/perfil")
    }

    static func proximaAula() async throws -> ProximaAulaProfessorDTO? {
        do {
            return try await APIClient.shared.request("/api/professor/proxima-aula") as ProximaAulaProfessorDTO
        } catch APIError.decoding {
            return nil
        }
    }

    static func estatisticas() async throws -> EstatisticasProfessorDTO {
        try await APIClient.shared.request("/api/professor/estatisticas")
    }

    static func turmas() async throws -> [TurmaDTO] {
        try await APIClient.shared.request("/api/professor/turmas")
    }

    static func turma(_ id: Int64) async throws -> TurmaDetalheDTO {
        try await APIClient.shared.request("/api/professor/turmas/\(id)")
    }

    static func alunosDaTurma(_ id: Int64) async throws -> [AlunoTurmaDTO] {
        try await APIClient.shared.request("/api/professor/turmas/\(id)/alunos")
    }

    static func historicoDaTurma(_ id: Int64) async throws -> [ChamadaPassadaDTO] {
        try await APIClient.shared.request("/api/professor/turmas/\(id)/historico")
    }

    static func historico() async throws -> [ChamadaPassadaDTO] {
        try await APIClient.shared.request("/api/professor/historico")
    }

    static func chamadaDetalhe(_ id: Int64) async throws -> ChamadaDetalheDTO {
        try await APIClient.shared.request("/api/professor/chamadas/\(id)/detalhe")
    }

    static func atualizarPerfil(_ dto: UpdatePerfilProfessorDTO) async throws -> PerfilProfessorDTO {
        try await APIClient.shared.request("/api/professor/perfil",
                                           method: .patch,
                                           body: dto)
    }
}
