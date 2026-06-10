import Foundation

// MARK: - Status de frequência

enum StatusFrequencia: String, Decodable {
    case ok = "OK"
    case alerta = "ALERTA"
    case emRisco = "EM_RISCO"
    case reprovado = "REPROVADO"
}

// MARK: - Busca de aluno

struct AlunoBuscaDTO: Decodable, Identifiable, Hashable {
    let alunoId: Int64
    let nome: String
    let ra: String?
    let email: String?

    var id: Int64 { alunoId }
}

// MARK: - Métricas

struct FaltasPorMateriaDTO: Decodable, Identifiable, Hashable {
    let materiaId: Int64
    let materiaNome: String
    let cargaHoraria: Int?
    let faltas: Int
    let limite: Int
    let percentual: Int
    let status: StatusFrequencia

    var id: Int64 { materiaId }
}

struct AlunoResumoDTO: Decodable, Identifiable, Hashable {
    let alunoId: Int64
    let nome: String
    let ra: String?
    let materias: [FaltasPorMateriaDTO]
    let materiasEmRisco: Int
    let materiasReprovadas: Int

    var id: Int64 { alunoId }
}

struct TurmaResumoDTO: Decodable, Identifiable, Hashable {
    let turmaId: Int64
    let turmaNome: String
    let anoSemestre: String
    let totalAlunos: Int
    let alunosEmRisco: Int
    let alunosReprovados: Int
    let alunos: [AlunoResumoDTO]

    var id: Int64 { turmaId }
}

// MARK: - Curso

struct CursoResponseDTO: Decodable, Identifiable, Hashable {
    let id: Int64
    let codigo: String
    let nome: String
    let totalAlunos: Int
    let totalMaterias: Int
}

struct CreateCursoRequestDTO: Encodable {
    let codigo: String
    let nome: String
}

struct UpdateCursoRequestDTO: Encodable {
    let codigo: String?
    let nome: String?
}

// MARK: - Grupo derivado (curso + anoIngresso + subturma)

struct GrupoDTO: Decodable, Identifiable, Hashable {
    let cursoId: Int64
    let cursoCodigo: String
    let anoIngresso: String
    let subturma: String?
    let label: String
    let totalAlunos: Int

    var id: String {
        "\(cursoId)|\(anoIngresso)|\(subturma ?? "")"
    }
}

struct TurmaIdsRequestDTO: Encodable {
    let ids: [Int64]
}

// MARK: - Aluno detail

struct AlunoDetailDTO: Decodable, Identifiable, Hashable {
    let alunoId: Int64
    let nome: String
    let email: String?
    let ra: String?
    let phone: String?
    let anoIngresso: String?
    let subturma: String?
    let cursoId: Int64?
    let cursoCodigo: String?
    let cursoNome: String?
    let turmaLabel: String?
    let faltasPorMateria: [FaltasPorMateriaDTO]
    let materiasEmRisco: Int
    let materiasReprovadas: Int

    var id: Int64 { alunoId }
}

struct AusenciaDTO: Decodable, Identifiable, Hashable {
    let presencaId: Int64
    let chamadaId: Int64
    let materiaId: Int64
    let materiaNome: String
    let data: String?         // ISO LocalDateTime
    let sala: String?
    let abonado: Bool
    let motivoAbono: String?

    var id: Int64 { presencaId }
}

// MARK: - Matérias

struct MateriaListDTO: Decodable, Identifiable, Hashable {
    let id: Int64
    let nome: String
    let codigo: String?
    let sala: String?
    let horarioSemanal: String?
    let cargaHoraria: Int?
    let periodoId: Int64?
    let periodoNome: String?
    let cursoId: Int64?
    let cursoCodigo: String?
    let cursoNome: String?
    let totalAlunos: Int
}

struct CreateMateriaRequestDTO: Encodable {
    let nome: String
    let codigo: String?
    let sala: String?
    let horarioSemanal: String?
    let cargaHoraria: Int
    let periodoId: Int64
    let cursoId: Int64?
}

struct UpdateMateriaRequestDTO: Encodable {
    let nome: String?
    let codigo: String?
    let sala: String?
    let horarioSemanal: String?
    let cargaHoraria: Int?
    let periodoId: Int64?
    let cursoId: Int64?
}

// MARK: - Professor

struct ProfessorListDTO: Decodable, Identifiable, Hashable {
    let professorId: Int64
    let nome: String
    let ra: String?
    let email: String?
    let department: String?

    var id: Int64 { professorId }
}

// MARK: - Matéria detail

struct MateriaDetailDTO: Decodable, Identifiable, Hashable {
    let id: Int64
    let nome: String
    let codigo: String?
    let sala: String?
    let horarioSemanal: String?
    let cargaHoraria: Int?
    let periodoId: Int64?
    let periodoNome: String?
    let cursoId: Int64?
    let cursoCodigo: String?
    let cursoNome: String?
    let professores: [ProfessorListDTO]
    let alunos: [AlunoBuscaDTO]
}

// MARK: - Periodo (pra picker)

struct PeriodoResponseDTO: Decodable, Identifiable, Hashable {
    let id: Int64
    let nome: String
}

struct CreatePeriodoRequestDTO: Encodable {
    let nome: String
}

// MARK: - Aluno register (pela coordenação)

struct RegisterAlunoFormDTO: Encodable {
    let username: String
    let email: String
    let password: String
    let faceId: String?
    let raAluno: String
    let anoIngresso: String?
    let subturma: String?
    let cursoId: Int64?
}

// MARK: - Busca universal

struct UniversalSearchDTO: Decodable {
    let alunos: [AlunoBuscaDTO]
    let professores: [ProfessorListDTO]
    let materias: [MateriaListDTO]
    let cursos: [CursoResponseDTO]

    var isEmpty: Bool {
        alunos.isEmpty && professores.isEmpty && materias.isEmpty && cursos.isEmpty
    }
    var totalCount: Int {
        alunos.count + professores.count + materias.count + cursos.count
    }
}

// MARK: - Professor register (pela coordenação)

struct RegisterProfessorFormDTO: Encodable {
    let username: String
    let email: String
    let password: String
    let raProfessor: String
    let periodoIds: [Int64]
    let materiaIds: [Int64]
}

// MARK: - Abono

struct AbonoRequestDTO: Encodable {
    let presencaIds: [Int64]
    let motivo: String?
}

struct AbonoPorPeriodoRequestDTO: Encodable {
    let alunoId: Int64
    let materiaId: Int64?
    let dataInicio: String   // YYYY-MM-DD
    let dataFim: String      // YYYY-MM-DD
    let motivo: String?
}

struct AbonoResponseDTO: Decodable {
    let abonadas: Int?
    let revertidas: Int?
}
