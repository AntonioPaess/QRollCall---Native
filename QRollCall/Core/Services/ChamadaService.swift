import Foundation

@MainActor
struct ChamadaService {
    static func create(_ dto: RegisterChamadaRequestDTO) async throws -> ChamadaCreatedDTO {
        try await APIClient.shared.request("/api/chamada/create",
                                           method: .post,
                                           body: dto)
    }

    static func live(_ idChamada: Int64) async throws -> LiveAttendanceDTO {
        try await APIClient.shared.request("/api/chamada/\(idChamada)/live")
    }

    static func encerrar(_ idChamada: Int64) async throws {
        _ = try await APIClient.shared.send("/api/chamada/\(idChamada)/encerrar",
                                            method: .post,
                                            body: Optional<String>.none)
    }

    static func encerrarComResumo(_ idChamada: Int64, resumo: EncerrarComResumoDTO) async throws {
        _ = try await APIClient.shared.send("/api/chamada/\(idChamada)/encerrar-com-resumo",
                                            method: .post,
                                            body: resumo)
    }

    static func verificarChamada(_ qrcodeId: String) async throws -> ChamadaStateDTO {
        try await APIClient.shared.request("/api/chamada/verificar/\(qrcodeId)",
                                           authenticated: false)
    }

    /// Heartbeat do prof: sinaliza ao backend que o app está vivo e transmitindo.
    /// Backend bloqueia novas presenças se não receber por > 15s.
    static func heartbeat(_ idChamada: Int64) async throws {
        _ = try await APIClient.shared.send("/api/chamada/\(idChamada)/heartbeat",
                                            method: .post,
                                            body: Optional<String>.none)
    }
}

@MainActor
struct PresencaService {
    static func registrar(_ dto: PresencaRequestDTO) async throws -> PresencaResponseDTO {
        try await APIClient.shared.request("/api/presenca/registrar",
                                           method: .post,
                                           body: dto)
    }

    static func verificarCodigo(_ dto: VerificarCodigoRequestDTO) async throws -> Bool {
        try await APIClient.shared.request("/api/presenca/verificar-codigo",
                                           method: .post,
                                           body: dto)
    }

    /// Pré-check de proximidade — antes de pedir Face ID etc.
    /// Retorna `true` se o aluno está dentro do raio do beacon do prof e a chamada
    /// está ativa (heartbeat recente). Retorna `false` se 403 ou unauthorized.
    static func verificarProximidade(qrcodeId: String,
                                     proximity: String,
                                     accuracy: Double) async throws -> Bool {
        do {
            _ = try await APIClient.shared.send("/api/presenca/verifica-proximidade",
                                                 method: .post,
                                                 body: VerificarProximidadeRequestDTO(
                                                    qrcodeId: qrcodeId,
                                                    beaconProximity: proximity,
                                                    beaconAccuracy: accuracy
                                                 ))
            return true
        } catch APIError.server(let status, _) where status == 403 {
            return false
        } catch APIError.unauthorized {
            return false
        }
    }
}
