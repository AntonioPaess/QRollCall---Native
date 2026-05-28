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

    static func verificarLocalizacao(qrcodeId: String, latitude: Double, longitude: Double) async throws -> Bool {
        do {
            _ = try await APIClient.shared.send("/api/presenca/verifica-localizacao",
                                                 method: .post,
                                                 body: VerificarLocalizacaoRequestDTO(
                                                    qrcodeId: qrcodeId,
                                                    latitude: latitude,
                                                    longitude: longitude
                                                 ))
            return true
        } catch APIError.server(let status, _) where status == 403 {
            return false
        } catch APIError.unauthorized {
            return false
        }
    }
}
