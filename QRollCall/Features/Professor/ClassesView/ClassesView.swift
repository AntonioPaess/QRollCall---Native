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
                            .font(.system(size: AppDimens.fontCaption))
                            .foregroundColor(AppColors.error)
                    }
                    if viewModel.turmas.isEmpty && !viewModel.isLoading {
                        Text("Você ainda não tem turmas.")
                            .font(.system(size: AppDimens.fontCaption))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.top, AppDimens.spacingXL)
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
                .padding(.vertical, AppDimens.spacingLG)
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
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(cls.nome)
                        .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(cls.codigo) • \(cls.horarioSemanal)")
                        .font(.system(size: AppDimens.fontCaption, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: AppDimens.iconSM, weight: .medium))
                    .foregroundColor(AppColors.textTertiary)
            }

            HStack(spacing: AppDimens.spacingLG) {
                miniStat(icon: AppIcons.people, value: "\(cls.totalStudents)", label: AppStrings.students)
                miniStat(icon: AppIcons.chartUp, value: "\(cls.averagePresence)%", label: AppStrings.presence)

                if cls.studentsAtRisk > 0 {
                    miniStat(icon: AppIcons.exclamation, value: "\(cls.studentsAtRisk)", label: AppStrings.atRisk, color: AppColors.warning)
                }
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func miniStat(icon: String, value: String, label: String, color: Color = AppColors.textSecondary) -> some View {
        HStack(spacing: AppDimens.spacingXS) {
            Image(systemName: icon)
                .font(.system(size: AppDimens.iconSM))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: AppDimens.fontSmall, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(label)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

#Preview {
    ClassesView()
}
