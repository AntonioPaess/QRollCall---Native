//
//  ProfessorSearchContent.swift
//  QRollCall
//
//  Busca do professor: filtra as próprias turmas (que já carrega via
//  ClassesViewModel) por nome ou código. Mesmo padrão Liquid Glass do Coord.
//

import Combine
import SwiftUI

@MainActor
final class ProfessorSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var turmas: [TurmaDTO] = []
    @Published private(set) var isLoading = false

    var filteredTurmas: [TurmaDTO] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return turmas.filter {
            $0.nome.lowercased().contains(q)
                || $0.codigo.lowercased().contains(q)
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            turmas = try await ProfessorService.turmas()
        } catch {
            turmas = []
        }
    }
}

struct ProfessorSearchContent: View {
    @StateObject private var vm = ProfessorSearchViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                if vm.query.isEmpty {
                    EmptyState(
                        icon: "magnifyingglass",
                        title: "Buscar nas suas turmas",
                        subtitle: "Digite nome ou código da matéria."
                    )
                    .padding(.top, AppDimens.spacingXXL)
                } else if vm.filteredTurmas.isEmpty {
                    EmptyState(
                        icon: "questionmark.circle",
                        title: "Nenhuma turma encontrada",
                        subtitle: "Tente outro termo."
                    )
                    .padding(.top, AppDimens.spacingXXL)
                } else {
                    VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
                        SectionHeader(title: "Suas turmas")
                        ForEach(vm.filteredTurmas) { turma in
                            NavigationLink(destination: ClassDetailView(turma: turma)) {
                                TurmaSearchRow(turma: turma)
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
        .navigationTitle("Buscar")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $vm.query, prompt: "Nome ou código da turma")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .task { await vm.load() }
    }
}

private struct TurmaSearchRow: View {
    let turma: TurmaDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: AppIcons.classes)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(turma.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(turma.codigo) · \(turma.totalStudents) alunos")
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
}
