import Foundation

struct RegisterChamadaRequestDTO: Encodable {
    let horarios: String?
    let turma: String?
    let segundos: Int
    let materiaId: Int64
    let latitude: Double?
    let longitude: Double?
    let classType: String
    let sala: String?
    let keywords: [String]
}

struct ChamadaCreatedDTO: Decodable {
    let idChamada: Int64
    let idQrcode: String
    let codigo: String
}

struct ChamadaStateDTO: Decodable {
    let estado: String
    let tempoRestante: Int64?
    let mensagem: String?
}

struct LiveAttendanceDTO: Decodable {
    let idChamada: Int64
    let estado: String
    let confirmedCount: Int
    let totalStudents: Int
    let timeRemainingSec: Int64
    let confirmados: [ConfirmadoDTO]

    struct ConfirmadoDTO: Decodable, Identifiable {
        let alunoId: Int64
        let name: String
        let matricula: String
        let confirmedAt: String?

        var id: Int64 { alunoId }
    }
}

struct EncerrarComResumoDTO: Encodable {
    let alunosPresentes: [Int64]
    let alunosAusentes: [Int64]
}

struct PresencaRequestDTO: Encodable {
    let qrcodeId: String
    let faceVerified: Bool
    let latitude: Double
    let longitude: Double
    let codigo: String
}

struct PresencaResponseDTO: Decodable {
    let presencaId: Int64
    let status: String
    let verificacoes: Verificacoes

    struct Verificacoes: Decodable {
        let facial: Bool
        let codigo: Bool
        let localizacao: Bool
        let horario: Bool
    }
}

struct VerificarCodigoRequestDTO: Encodable {
    let qrcodeId: String
    let codigo: String
}

struct VerificarLocalizacaoRequestDTO: Encodable {
    let qrcodeId: String
    let latitude: Double
    let longitude: Double
}
