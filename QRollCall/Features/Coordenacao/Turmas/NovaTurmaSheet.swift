//
//  NovaTurmaSheet.swift
//  QRollCall
//
//  Turma é um conceito derivado: ela emerge quando há pelo menos um aluno com
//  a tupla (curso, anoIngresso, subturma). Este sheet cria a turma cadastrando
//  o primeiro aluno dela.
//

import SwiftUI

struct NovaTurmaSheet: View {
    let curso: CursoResponseDTO
    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var anoIngresso = ""
    @State private var subturma = ""
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var ra = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        !anoIngresso.trimmingCharacters(in: .whitespaces).isEmpty
            && !nome.trimmingCharacters(in: .whitespaces).isEmpty
            && !email.trimmingCharacters(in: .whitespaces).isEmpty
            && !senha.isEmpty
            && !ra.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var previewLabel: String {
        let ing = anoIngresso.trimmingCharacters(in: .whitespaces)
        let sub = subturma.trimmingCharacters(in: .whitespaces).uppercased()
        guard !ing.isEmpty else { return "\(curso.codigo)-…" }
        return sub.isEmpty ? "\(curso.codigo)-\(ing)" : "\(curso.codigo)-\(ing)-\(sub)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Curso")
                        Spacer()
                        Text(curso.codigo)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    TextField("Ano de ingresso (ex: 2025.1)", text: $anoIngresso)
                        .keyboardType(.decimalPad)
                    TextField("Subturma — A, B, C… (opcional)", text: $subturma)
                        .textInputAutocapitalization(.characters)
                } header: {
                    Text("Identificação")
                } footer: {
                    HStack(spacing: 6) {
                        Text("Será criada a turma")
                        Text(previewLabel)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppColors.primaryStrong)
                    }
                }

                Section {
                    TextField("Nome completo", text: $nome)
                    TextField("E-mail", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Senha inicial", text: $senha)
                    TextField("RA / Matrícula", text: $ra)
                } header: {
                    Text("Primeiro aluno")
                } footer: {
                    Text("Uma turma é o conjunto de alunos do mesmo curso e ingresso. "
                         + "Para a turma existir, ao menos um aluno precisa ser cadastrado.")
                }

                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(AppColors.danger) }
                }
            }
            .navigationTitle("Nova turma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSubmitting ? "..." : "Criar turma") {
                        Task { await submit() }
                    }
                    .disabled(!canSubmit || isSubmitting)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let dto = RegisterAlunoFormDTO(
                username: nome.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: senha,
                faceId: nil,
                raAluno: ra.trimmingCharacters(in: .whitespaces),
                anoIngresso: anoIngresso.trimmingCharacters(in: .whitespaces),
                subturma: subturma.trimmingCharacters(in: .whitespaces).isEmpty
                    ? nil : subturma.uppercased(),
                cursoId: curso.id
            )
            try await CoordenacaoService.registrarAluno(dto)
            onCreated()
            dismiss()
        } catch {
            errorMessage = "Erro ao criar turma. Verifique se o RA/e-mail já existe."
        }
    }
}
