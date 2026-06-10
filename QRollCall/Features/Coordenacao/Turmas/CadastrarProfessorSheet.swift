//
//  CadastrarProfessorSheet.swift
//  QRollCall
//

import SwiftUI

struct CadastrarProfessorSheet: View {
    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var ra = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty
            && !email.trimmingCharacters(in: .whitespaces).isEmpty
            && !senha.isEmpty
            && !ra.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dados do professor") {
                    TextField("Nome completo", text: $nome)
                    TextField("E-mail", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Senha inicial", text: $senha)
                    TextField("RA / Identificador", text: $ra)
                }
                Section {
                    Text("A associação a matérias é feita depois, no detalhe de cada matéria.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(AppColors.danger) }
                }
            }
            .navigationTitle("Novo professor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSubmitting ? "..." : "Cadastrar") { Task { await submit() } }
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
            let dto = RegisterProfessorFormDTO(
                username: nome.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: senha,
                raProfessor: ra.trimmingCharacters(in: .whitespaces),
                periodoIds: [],
                materiaIds: []
            )
            try await CoordenacaoService.registrarProfessor(dto)
            onCreated()
            dismiss()
        } catch {
            errorMessage = "Erro ao cadastrar. Verifique se o e-mail/RA já existe."
        }
    }
}
