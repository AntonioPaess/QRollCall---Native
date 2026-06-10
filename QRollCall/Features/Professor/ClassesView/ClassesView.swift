//
//  ClassesView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ClassesView: View {
    @StateObject private var viewModel = ClassesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppDimens.spacingMD) {
                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.danger)
                    }
                    if viewModel.turmas.isEmpty && !viewModel.isLoading {
                        EmptyState(
                            icon: AppIcons.people,
                            title: "Você ainda não tem turmas",
                            subtitle: "Quando a coordenação te associar a uma matéria, as turmas aparecem aqui."
                        )
                    } else {
                        ForEach(viewModel.turmas) { cls in
                            NavigationLink(destination: ClassDetailView(turma: cls)) {
                                classCard(cls)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(AppStrings.classesTitle)
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    private func classCard(_ cls: TurmaDTO) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
            HStack(spacing: AppDimens.spacingMD) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.surfaceMuted)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: AppIcons.classes)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.primaryStrong)
                    }
                VStack(alignment: .leading, spacing: 3) {
                    Text(cls.nome)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("\(cls.codigo) · \(cls.horarioSemanal)")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }

            HStack(spacing: 0) {
                miniStat(value: "\(cls.totalStudents)", label: AppStrings.students)
                Spacer()
                Rectangle().fill(AppColors.hairline).frame(width: 1, height: 28)
                Spacer()
                miniStat(value: "\(cls.averagePresence)%",
                         label: AppStrings.presence,
                         accent: AppColors.success)
                if cls.studentsAtRisk > 0 {
                    Spacer()
                    Rectangle().fill(AppColors.hairline).frame(width: 1, height: 28)
                    Spacer()
                    miniStat(value: "\(cls.studentsAtRisk)",
                             label: AppStrings.atRisk,
                             accent: AppColors.warning)
                }
            }
        }
        .padding(AppDimens.spacingLG)
        .minimalCard(corner: 16)
    }

    private func miniStat(value: String, label: String, accent: Color = AppColors.textPrimary) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

#Preview {
    ClassesView()
}
