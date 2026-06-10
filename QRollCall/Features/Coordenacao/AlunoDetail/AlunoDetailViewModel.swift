//
//  AlunoDetailViewModel.swift
//  QRollCall
//

import Combine
import Foundation

@MainActor
final class AlunoDetailViewModel: ObservableObject {
    let alunoId: Int64

    @Published private(set) var detail: AlunoDetailDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(alunoId: Int64) {
        self.alunoId = alunoId
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            detail = try await CoordenacaoService.alunoDetail(alunoId: alunoId)
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar os dados do aluno."
        }
    }
}

@MainActor
final class AusenciasViewModel: ObservableObject {
    let alunoId: Int64
    let materiaId: Int64
    let materiaNome: String

    @Published private(set) var ausencias: [AusenciaDTO] = []
    @Published var selecionadas: Set<Int64> = []
    @Published var motivo: String = ""
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var lastAbonadas: Int?

    init(alunoId: Int64, materiaId: Int64, materiaNome: String) {
        self.alunoId = alunoId
        self.materiaId = materiaId
        self.materiaNome = materiaNome
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            ausencias = try await CoordenacaoService.ausencias(alunoId: alunoId, materiaId: materiaId)
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar as faltas."
        }
    }

    func toggle(_ id: Int64) {
        if selecionadas.contains(id) {
            selecionadas.remove(id)
        } else {
            selecionadas.insert(id)
        }
    }

    var canConfirm: Bool { !selecionadas.isEmpty && !isSubmitting }

    func abonar() async {
        guard canConfirm else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let resp = try await CoordenacaoService.abonar(
                presencaIds: Array(selecionadas),
                motivo: motivo.isEmpty ? nil : motivo
            )
            lastAbonadas = resp.abonadas
            selecionadas.removeAll()
            motivo = ""
            await load()
        } catch {
            errorMessage = "Erro ao abonar."
        }
    }
}
