import Foundation

struct PerfilProfessorDTO: Decodable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let department: String
    let classesGiven: Int
    let averagePresence: Int
    let activeClasses: Int
    let totalStudents: Int?
}

struct ProximaAulaProfessorDTO: Decodable {
    let nome: String
    let startTime: String
    let endTime: String
    let sala: String
    let totalStudents: Int
}

struct EstatisticasProfessorDTO: Decodable {
    let averagePresence: Int
    let classesGiven: Int
}

struct TurmaDTO: Decodable, Identifiable {
    let id: Int64
    let nome: String
    let codigo: String
    let sala: String
    let horarioSemanal: String
    let totalStudents: Int
    let averagePresence: Int
    let studentsAtRisk: Int
}

struct AlunoTurmaDTO: Decodable, Identifiable {
    let id: Int64
    let name: String
    let matricula: String
    let presencePercentage: Int
    let atRisk: Bool
}

struct TurmaDetalheDTO: Decodable {
    let turma: TurmaDTO
    let alunos: [AlunoTurmaDTO]
}

struct ChamadaPassadaDTO: Decodable, Identifiable {
    let id: Int64
    let className: String
    let date: String
    let time: String
    let presentCount: Int
    let totalCount: Int
    let presencePercentage: Int
    let classType: String?
}

struct ChamadaDetalheDTO: Decodable {
    let id: Int64
    let className: String
    let date: String
    let time: String
    let classType: String?
    let sala: String?
    let presentes: [AlunoStatusDTO]
    let ausentes: [AlunoStatusDTO]

    struct AlunoStatusDTO: Decodable, Identifiable {
        let alunoId: Int64
        let presencaId: Int64?
        let name: String
        let matricula: String
        let confirmedAt: String?
        let status: String

        var id: Int64 { alunoId }
    }
}

struct UpdatePerfilProfessorDTO: Encodable {
    let phone: String?
    let department: String?
}
