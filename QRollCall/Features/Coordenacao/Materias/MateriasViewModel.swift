//
//  MateriasViewModel.swift
//  QRollCall
//

import Combine
import Foundation

@MainActor
final class MateriasViewModel: ObservableObject {
    @Published private(set) var materias: [MateriaListDTO] = []
    @Published private(set) var cursos: [CursoResponseDTO] = []
    @Published private(set) var periodos: [PeriodoResponseDTO] = []
    @Published var search: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Form
    @Published var showCreate = false
    @Published var formNome = ""
    @Published var formCodigo = ""
    @Published var formSala = ""
    @Published var formCargaHoraria: Int = 60
    @Published var formCursoId: Int64?
    @Published var formPeriodoId: Int64?
    @Published var isSubmitting = false

    /// Agrupado por curso (nome do curso, lista de matérias).
    var grouped: [(String, [MateriaListDTO])] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        let filtered = q.isEmpty ? materias : materias.filter {
            $0.nome.lowercased().contains(q) ||
            ($0.codigo?.lowercased().contains(q) ?? false) ||
            ($0.cursoCodigo?.lowercased().contains(q) ?? false)
        }
        let dict = Dictionary(grouping: filtered) { mat -> String in
            mat.cursoCodigo ?? "Sem curso"
        }
        return dict.sorted { $0.key < $1.key }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let mTask = CoordenacaoService.listarMaterias()
            async let cTask = CoordenacaoService.listarCursos()
            async let pTask = CoordenacaoService.listarPeriodos()
            materias = try await mTask
            cursos = try await cTask
            periodos = try await pTask
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar."
        }
    }

    func resetForm() {
        formNome = ""
        formCodigo = ""
        formSala = ""
        formCargaHoraria = 60
        formCursoId = cursos.first?.id
        formPeriodoId = periodos.first?.id
    }

    var canSubmit: Bool {
        !formNome.trimmingCharacters(in: .whitespaces).isEmpty
            && formPeriodoId != nil
            && formCargaHoraria > 0
    }

    func criar() async {
        guard canSubmit, let pid = formPeriodoId else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let dto = CreateMateriaRequestDTO(
                nome: formNome.trimmingCharacters(in: .whitespaces),
                codigo: formCodigo.isEmpty ? nil : formCodigo,
                sala: formSala.isEmpty ? nil : formSala,
                horarioSemanal: nil,
                cargaHoraria: formCargaHoraria,
                periodoId: pid,
                cursoId: formCursoId
            )
            try await CoordenacaoService.criarMateria(dto)
            showCreate = false
            await load()
        } catch {
            errorMessage = "Erro ao criar matéria."
        }
    }

    func criarPeriodoRapido(nome: String) async {
        do {
            let novo = try await CoordenacaoService.criarPeriodo(nome: nome)
            periodos.append(novo)
            formPeriodoId = novo.id
        } catch {
            errorMessage = "Erro ao criar período."
        }
    }
}
