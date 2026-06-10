//
//  CreateMateriaForCursoSheet.swift
//  QRollCall
//
//  Sheet para criar matéria com curso pré-selecionado, usada no Curso Detail.
//

import SwiftUI

struct CreateMateriaForCursoSheet: View {
    let cursoId: Int64
    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nome = ""
    @State private var codigo = ""
    @State private var sala = ""
    @State private var cargaHoraria: Int = 60
    @State private var periodos: [PeriodoResponseDTO] = []
    @State private var periodoId: Int64?
    @State private var novoPeriodoNome = ""
    @State private var showAddPeriodo = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty && periodoId != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dados") {
                    TextField("Nome", text: $nome)
                    TextField("Código (ex: POO)", text: $codigo)
                        .textInputAutocapitalization(.characters)
                    TextField("Sala", text: $sala)
                }
                Section("Carga horária") {
                    Picker("Carga horária", selection: $cargaHoraria) {
                        Text("45h (1 dia = 3 faltas)").tag(45)
                        Text("60h (1 dia = 2 faltas)").tag(60)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section("Período") {
                    if periodos.isEmpty {
                        HStack {
                            TextField("Ex: 1º semestre", text: $novoPeriodoNome)
                            Button("Criar") { Task { await criarPeriodo() } }
                                .disabled(novoPeriodoNome.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    } else {
                        Picker("Período", selection: $periodoId) {
                            ForEach(periodos) { p in
                                Text(p.nome).tag(Int64?.some(p.id))
                            }
                        }
                        Button("Adicionar período") { showAddPeriodo = true }
                            .font(.system(size: 13))
                    }
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(AppColors.danger) }
                }
            }
            .navigationTitle("Nova matéria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSubmitting ? "..." : "Criar") {
                        Task { await submit() }
                    }
                    .disabled(!canSubmit || isSubmitting)
                    .fontWeight(.semibold)
                }
            }
            .alert("Adicionar período", isPresented: $showAddPeriodo) {
                TextField("Nome", text: $novoPeriodoNome)
                Button("Criar") { Task { await criarPeriodo() } }
                Button("Cancelar", role: .cancel) {}
            }
            .task { await loadPeriodos() }
        }
    }

    private func loadPeriodos() async {
        do {
            periodos = try await CoordenacaoService.listarPeriodos()
            if periodoId == nil { periodoId = periodos.first?.id }
        } catch {
            errorMessage = "Não foi possível carregar períodos."
        }
    }

    private func criarPeriodo() async {
        let nome = novoPeriodoNome.trimmingCharacters(in: .whitespaces)
        guard !nome.isEmpty else { return }
        do {
            let novo = try await CoordenacaoService.criarPeriodo(nome: nome)
            periodos.append(novo)
            periodoId = novo.id
            novoPeriodoNome = ""
        } catch {
            errorMessage = "Erro ao criar período."
        }
    }

    private func submit() async {
        guard let pid = periodoId else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let dto = CreateMateriaRequestDTO(
                nome: nome.trimmingCharacters(in: .whitespaces),
                codigo: codigo.isEmpty ? nil : codigo,
                sala: sala.isEmpty ? nil : sala,
                horarioSemanal: nil,
                cargaHoraria: cargaHoraria,
                periodoId: pid,
                cursoId: cursoId
            )
            try await CoordenacaoService.criarMateria(dto)
            onCreated()
            dismiss()
        } catch {
            errorMessage = "Erro ao criar matéria."
        }
    }
}
