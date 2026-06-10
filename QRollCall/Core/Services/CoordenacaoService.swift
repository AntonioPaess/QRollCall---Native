import Foundation

@MainActor
struct CoordenacaoService {

    // MARK: - Cursos

    static func listarCursos() async throws -> [CursoResponseDTO] {
        try await APIClient.shared.request("/api/coordenacao/cursos",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    static func criarCurso(_ dto: CreateCursoRequestDTO) async throws -> CursoResponseDTO {
        try await APIClient.shared.request("/api/coordenacao/cursos",
                                           method: .post,
                                           body: dto,
                                           authenticated: true)
    }

    static func atualizarCurso(id: Int64, _ dto: UpdateCursoRequestDTO) async throws -> CursoResponseDTO {
        try await APIClient.shared.request("/api/coordenacao/cursos/\(id)",
                                           method: .patch,
                                           body: dto,
                                           authenticated: true)
    }

    static func removerCurso(id: Int64) async throws {
        _ = try await APIClient.shared.send("/api/coordenacao/cursos/\(id)",
                                            method: .delete,
                                            body: EmptyBody?.none,
                                            authenticated: true)
    }

    // MARK: - Grupos derivados

    /// Lista grupos (curso + anoIngresso + subturma). Filtra por cursoId opcional.
    static func listarGrupos(cursoId: Int64? = nil) async throws -> [GrupoDTO] {
        var q: [String: String] = [:]
        if let cursoId { q["cursoId"] = String(cursoId) }
        return try await APIClient.shared.request("/api/coordenacao/grupos",
                                                  method: .get,
                                                  query: q,
                                                  body: EmptyBody?.none,
                                                  authenticated: true)
    }

    // MARK: - Busca de aluno

    static func buscarAlunos(query: String) async throws -> [AlunoBuscaDTO] {
        try await APIClient.shared.request("/api/coordenacao/alunos/buscar",
                                           method: .get,
                                           query: ["q": query],
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    /// Lista alunos de um curso (todas turmas combinadas).
    static func alunosDoCurso(cursoId: Int64) async throws -> [AlunoBuscaDTO] {
        try await APIClient.shared.request("/api/coordenacao/curso/\(cursoId)/alunos",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    // MARK: - Professores

    static func listarProfessores() async throws -> [ProfessorListDTO] {
        try await APIClient.shared.request("/api/coordenacao/professores",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    static func materiaDetail(materiaId: Int64) async throws -> MateriaDetailDTO {
        try await APIClient.shared.request("/api/coordenacao/materia/\(materiaId)",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    static func associarProfessorMateria(professorId: Int64, materiaId: Int64) async throws {
        struct Body: Encodable { let professorId: Int64; let materiaId: Int64 }
        _ = try await APIClient.shared.send("/api/coordenacao/professor-materia",
                                            method: .post,
                                            body: Body(professorId: professorId, materiaId: materiaId),
                                            authenticated: true)
    }

    static func desassociarProfessorMateria(professorId: Int64, materiaId: Int64) async throws {
        struct Body: Encodable { let professorId: Int64; let materiaId: Int64 }
        _ = try await APIClient.shared.send("/api/coordenacao/professor-materia",
                                            method: .delete,
                                            body: Body(professorId: professorId, materiaId: materiaId),
                                            authenticated: true)
    }

    // MARK: - Aluno detail + ausências

    static func alunoDetail(alunoId: Int64) async throws -> AlunoDetailDTO {
        try await APIClient.shared.request("/api/coordenacao/aluno/\(alunoId)",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    static func ausencias(alunoId: Int64, materiaId: Int64? = nil) async throws -> [AusenciaDTO] {
        var q: [String: String] = [:]
        if let materiaId { q["materiaId"] = String(materiaId) }
        return try await APIClient.shared.request("/api/coordenacao/aluno/\(alunoId)/ausencias",
                                                  method: .get,
                                                  query: q,
                                                  body: EmptyBody?.none,
                                                  authenticated: true)
    }

    // MARK: - Matérias

    static func listarMaterias(cursoId: Int64? = nil) async throws -> [MateriaListDTO] {
        var q: [String: String] = [:]
        if let cursoId { q["cursoId"] = String(cursoId) }
        return try await APIClient.shared.request("/api/coordenacao/materias",
                                                  method: .get,
                                                  query: q,
                                                  body: EmptyBody?.none,
                                                  authenticated: true)
    }

    static func criarMateria(_ dto: CreateMateriaRequestDTO) async throws {
        _ = try await APIClient.shared.send("/api/coordenacao/materias",
                                            method: .post,
                                            body: dto,
                                            authenticated: true)
    }

    static func atualizarMateria(id: Int64, _ dto: UpdateMateriaRequestDTO) async throws {
        _ = try await APIClient.shared.send("/api/coordenacao/materias/\(id)",
                                            method: .patch,
                                            body: dto,
                                            authenticated: true)
    }

    static func removerMateria(id: Int64) async throws {
        _ = try await APIClient.shared.send("/api/coordenacao/materias/\(id)",
                                            method: .delete,
                                            body: EmptyBody?.none,
                                            authenticated: true)
    }

    static func matricularAluno(alunoId: Int64, materiaId: Int64) async throws {
        struct Body: Encodable { let alunoId: Int64; let materiaId: Int64 }
        _ = try await APIClient.shared.send("/api/coordenacao/matriculas",
                                            method: .post,
                                            body: Body(alunoId: alunoId, materiaId: materiaId),
                                            authenticated: true)
    }

    static func desmatricularAluno(alunoId: Int64, materiaId: Int64) async throws {
        struct Body: Encodable { let alunoId: Int64; let materiaId: Int64 }
        _ = try await APIClient.shared.send("/api/coordenacao/matriculas",
                                            method: .delete,
                                            body: Body(alunoId: alunoId, materiaId: materiaId),
                                            authenticated: true)
    }

    // MARK: - Períodos

    static func listarPeriodos() async throws -> [PeriodoResponseDTO] {
        try await APIClient.shared.request("/api/coordenacao/periodos",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    static func criarPeriodo(nome: String) async throws -> PeriodoResponseDTO {
        try await APIClient.shared.request("/api/coordenacao/periodos",
                                           method: .post,
                                           body: CreatePeriodoRequestDTO(nome: nome),
                                           authenticated: true)
    }

    // MARK: - Registrar aluno (pelo fluxo da coordenação)

    static func registrarAluno(_ dto: RegisterAlunoFormDTO) async throws {
        _ = try await APIClient.shared.send("/api/auth/aluno/register",
                                            method: .post,
                                            body: dto,
                                            authenticated: false)
    }

    // MARK: - Abono

    static func abonar(presencaIds: [Int64], motivo: String?) async throws -> AbonoResponseDTO {
        let body = AbonoRequestDTO(presencaIds: presencaIds, motivo: motivo)
        return try await APIClient.shared.request("/api/coordenacao/abono",
                                                  method: .post,
                                                  body: body,
                                                  authenticated: true)
    }

    static func abonarPorPeriodo(_ dto: AbonoPorPeriodoRequestDTO) async throws -> AbonoResponseDTO {
        try await APIClient.shared.request("/api/coordenacao/abono/periodo",
                                           method: .post,
                                           body: dto,
                                           authenticated: true)
    }

    static func reverterAbono(presencaIds: [Int64]) async throws -> AbonoResponseDTO {
        let body = TurmaIdsRequestDTO(ids: presencaIds)
        return try await APIClient.shared.request("/api/coordenacao/abono/reverter",
                                                  method: .post,
                                                  body: body,
                                                  authenticated: true)
    }
}

@MainActor
struct MetricasService {

    static func faltasPorMateria(alunoId: Int64, materiaId: Int64) async throws -> FaltasPorMateriaDTO {
        try await APIClient.shared.request("/api/metricas/aluno/\(alunoId)/materia/\(materiaId)",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    static func resumoAluno(alunoId: Int64) async throws -> AlunoResumoDTO {
        try await APIClient.shared.request("/api/metricas/aluno/\(alunoId)",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    /// Resumo de um grupo derivado (curso + anoIngresso + subturma opcional).
    static func resumoGrupo(cursoId: Int64, anoIngresso: String, subturma: String? = nil) async throws -> TurmaResumoDTO {
        var q: [String: String] = [
            "cursoId": String(cursoId),
            "anoIngresso": anoIngresso
        ]
        if let sub = subturma, !sub.isEmpty {
            q["subturma"] = sub
        }
        return try await APIClient.shared.request("/api/metricas/grupo",
                                                  method: .get,
                                                  query: q,
                                                  body: EmptyBody?.none,
                                                  authenticated: true)
    }

    static func alunosEmRisco(materiaId: Int64) async throws -> [AlunoResumoDTO] {
        try await APIClient.shared.request("/api/metricas/materia/\(materiaId)/risco",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }

    /// Endpoint do aluno autenticado: faltas em cada matéria (alimenta o "3/15").
    static func minhasFaltas() async throws -> [FaltasPorMateriaDTO] {
        try await APIClient.shared.request("/api/aluno/faltas-por-materia",
                                           method: .get,
                                           body: EmptyBody?.none,
                                           authenticated: true)
    }
}

/// Placeholder para chamadas GET (sem body). APIClient não envia nada se for nil.
struct EmptyBody: Codable {}
