//
//  AlunoSearchSheet.swift
//  QRollCall
//

import Combine
import SwiftUI

@MainActor
final class AlunoSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [AlunoBuscaDTO] = []
    @Published var isSearching = false

    func search() async {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            results = []
            return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            let r = try await CoordenacaoService.buscarAlunos(query: q)
            guard q == query.trimmingCharacters(in: .whitespaces) else { return }
            results = r
        } catch is CancellationError {
            // ignore
        } catch {
            results = []
        }
    }
}

/// Conteúdo de busca de aluno. Usa `.searchable()` para se integrar com a barra de
/// busca do sistema (Liquid Glass tab role search no iOS 26).
struct AlunoSearchContent: View {
    @StateObject private var vm = AlunoSearchViewModel()
    var showCloseButton: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: AppDimens.spacingMD) {
                if vm.isSearching {
                    ProgressView().padding(.top, AppDimens.spacingLG)
                } else if !vm.query.isEmpty && vm.results.isEmpty {
                    EmptyState(icon: "person.crop.circle.badge.questionmark",
                               title: "Nenhum aluno encontrado")
                } else if vm.query.isEmpty {
                    EmptyState(icon: "magnifyingglass",
                               title: "Buscar aluno",
                               subtitle: "Digite o nome ou matrícula.")
                        .padding(.top, AppDimens.spacingXXL)
                } else {
                    LazyVStack(spacing: AppDimens.spacingSM) {
                        ForEach(vm.results) { aluno in
                            NavigationLink(value: aluno.alunoId) {
                                row(aluno)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, 120)
        }
        .background(AppColors.background)
        .navigationTitle("Buscar aluno")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $vm.query, prompt: "Nome ou matrícula")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .task(id: vm.query) {
            // Debounce 300ms; cancela automaticamente se o usuário continuar digitando.
            try? await Task.sleep(nanoseconds: 300_000_000)
            await vm.search()
        }
        .toolbar {
            if showCloseButton {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .navigationDestination(for: Int64.self) { id in
            AlunoDetailView(alunoId: id)
        }
    }

    private func row(_ a: AlunoBuscaDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: initials(a.nome), size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(a.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 4) {
                    if let ra = a.ra { Text("RA \(ra)") }
                    if let email = a.email, !email.isEmpty {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(email).lineLimit(1)
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }

    private func initials(_ s: String) -> String {
        let parts = s.split(separator: " ", maxSplits: 1)
        let f = parts.first?.first.map(String.init) ?? ""
        let l = parts.count > 1 ? parts[1].first.map(String.init) ?? "" : ""
        return "\(f)\(l)".uppercased()
    }
}

/// Wrapper sheet — útil quando a busca aparece sobreposta (não como aba).
struct AlunoSearchSheet: View {
    var body: some View {
        NavigationStack {
            AlunoSearchContent(showCloseButton: true)
        }
    }
}
