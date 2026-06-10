//
//  CoordenacaoTurmasViewModel.swift
//  QRollCall
//
//  Renomeado conceitualmente para "Cursos" — turma agora é grupo derivado
//  (curso + anoIngresso + subturma). Mantém o nome de arquivo por compatibilidade
//  com o target do Xcode.
//

import Combine
import Foundation

@MainActor
final class CoordenacaoTurmasViewModel: ObservableObject {
    @Published private(set) var cursos: [CursoResponseDTO] = []
    @Published var search: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Form de criar curso
    @Published var showCreate = false
    @Published var formCodigo: String = ""
    @Published var formNome: String = ""
    @Published var isSubmitting = false

    var filtered: [CursoResponseDTO] {
        let q = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return cursos }
        return cursos.filter {
            $0.codigo.lowercased().contains(q) || $0.nome.lowercased().contains(q)
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            cursos = try await CoordenacaoService.listarCursos()
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar os cursos."
        }
    }

    func criarCurso() async {
        let codigo = formCodigo.trimmingCharacters(in: .whitespaces)
        let nome = formNome.trimmingCharacters(in: .whitespaces)
        guard !codigo.isEmpty, !nome.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let dto = CreateCursoRequestDTO(codigo: codigo.uppercased(), nome: nome)
            let novo = try await CoordenacaoService.criarCurso(dto)
            cursos.append(novo)
            formCodigo = ""
            formNome = ""
            showCreate = false
        } catch {
            errorMessage = "Erro ao criar o curso."
        }
    }

    func removerCurso(id: Int64) async {
        do {
            try await CoordenacaoService.removerCurso(id: id)
            cursos.removeAll { $0.id == id }
        } catch {
            errorMessage = "Erro ao remover."
        }
    }
}
