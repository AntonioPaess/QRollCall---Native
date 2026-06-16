import Foundation

struct PerfilAlunoDTO: Decodable {
    let firstName: String
    let lastName: String
    let matricula: String
    let email: String
    let phone: String
    let course: String
    let semester: String
}

struct ProximaAulaDTO: Decodable {
    let nome: String
    let startTime: String
    let endTime: String
    let sala: String
    let timeUntil: String
    let progress: Double
}

struct EstatisticasAlunoDTO: Decodable {
    let presencePercentage: Int
    let presenceChange: String
    let totalClasses: Int
    let absences: Int
    let streakDays: Int
}

struct AtividadeDTO: Decodable, Identifiable {
    let id: Int64
    let className: String
    let date: String
    let time: String
    let status: String
}

struct HistoricoEntryDTO: Decodable, Identifiable {
    let id: Int64
    let className: String
    let date: String
    let time: String
    let sala: String
    let status: String
}

struct HistoricoSummaryDTO: Decodable {
    let presences: Int
    let absences: Int
    let rate: Int
}

struct HistoricoDTO: Decodable {
    let summary: HistoricoSummaryDTO
    let entries: [HistoricoEntryDTO]
}

struct ChamadaAtivaDTO: Decodable, Identifiable {
    let idChamada: Int64
    let idQrcode: String
    let materiaNome: String
    let sala: String
    let classType: String?
    let startTime: String
    let timeRemainingSec: Int64
    let jaRegistrouPresenca: Bool
    let keywords: [String]?
    let beaconUuid: String?
    let beaconMajor: Int?
    let beaconMinor: Int?

    var id: Int64 { idChamada }
}

struct UpdatePerfilAlunoDTO: Encodable {
    let phone: String?
    let course: String?
    let semester: String?
}
