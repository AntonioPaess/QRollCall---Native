//
//  CoordenacaoHomeViewModel.swift
//  QRollCall
//

import Combine
import Foundation

@MainActor
final class CoordenacaoHomeViewModel: ObservableObject {
    @Published private(set) var cursos: [CursoResponseDTO] = []
    @Published private(set) var grupos: [GrupoDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    /// Total de alunos somando todos os cursos.
    var totalAlunos: Int {
        cursos.reduce(0) { $0 + $1.totalAlunos }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let cursosTask = CoordenacaoService.listarCursos()
            async let gruposTask = CoordenacaoService.listarGrupos()
            cursos = try await cursosTask
            grupos = try await gruposTask
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar."
        }
    }
}
