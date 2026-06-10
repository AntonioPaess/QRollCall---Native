//
//  CoordenacaoHomeView.swift
//  QRollCall
//

import SwiftUI

struct CoordenacaoHomeView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var vm = CoordenacaoHomeViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: AppDimens.spacingMD),
        GridItem(.flexible(), spacing: AppDimens.spacingMD)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDimens.spacingXXL) {
                    PremiumHeader(
                        greeting: AppStrings.coordHomeGreeting,
                        title: auth.firstName.isEmpty ? AppStrings.coordHomeSubtitle : auth.firstName,
                        trailing: {
                            Avatar(initials: auth.initials, size: AppDimens.avatarSize)
                        }
                    )

                    kpiGrid

                    SectionHeader(title: "Turmas ativas",
                                  subtitle: "Grupos derivados por curso e ingresso")

                    if vm.isLoading && vm.grupos.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppDimens.spacingXXL)
                    } else if vm.grupos.isEmpty {
                        EmptyState(
                            icon: AppIcons.classes,
                            title: "Nenhuma turma ainda",
                            subtitle: "Cadastre cursos e alunos com ano de ingresso."
                        )
                    } else {
                        VStack(spacing: AppDimens.spacingMD) {
                            ForEach(vm.grupos) { grupo in
                                GrupoSummaryCard(grupo: grupo)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
            .refreshable { await vm.load() }
            .task { await vm.load() }
        }
    }

    private var kpiGrid: some View {
        LazyVGrid(columns: columns, spacing: AppDimens.spacingMD) {
            KPICard(
                title: AppStrings.coordKpiAlunos,
                value: "\(vm.totalAlunos)",
                icon: AppIcons.people,
                tint: AppColors.primary
            )
            KPICard(
                title: "Cursos",
                value: "\(vm.cursos.count)",
                icon: AppIcons.book,
                tint: AppColors.purple
            )
            KPICard(
                title: AppStrings.tabTurmas,
                value: "\(vm.grupos.count)",
                icon: AppIcons.classes,
                tint: AppColors.warning
            )
            KPICard(
                title: "Matérias",
                value: "\(vm.cursos.reduce(0) { $0 + $1.totalMaterias })",
                icon: AppIcons.doc,
                tint: AppColors.error
            )
        }
    }
}

private struct GrupoSummaryCard: View {
    let grupo: GrupoDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingLG) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: AppIcons.classes)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(grupo.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(grupo.totalAlunos) aluno\(grupo.totalAlunos == 1 ? "" : "s")")
                    .font(.system(size: 13))
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

#Preview {
    CoordenacaoHomeView()
        .environmentObject(AuthSession.shared)
}
