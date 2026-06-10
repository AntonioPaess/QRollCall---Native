//
//  ClassDetailView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ClassDetailView: View {
    let turma: TurmaDTO
    @StateObject private var viewModel = ClassDetailViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppDimens.spacingXL) {
                classInfoHeader
                if !viewModel.atRisk.isEmpty {
                    atRiskSection
                }
                studentsSection
                historySection
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.vertical, AppDimens.spacingLG)
        }
        .background(AppColors.background)
        .navigationTitle(turma.nome)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load(turmaId: turma.id) }
        .refreshable { await viewModel.load(turmaId: turma.id) }
    }

    private var classInfoHeader: some View {
        let info = viewModel.detalhe?.turma ?? turma
        return HStack(spacing: 0) {
            infoColumn(value: "\(info.totalStudents)", label: AppStrings.students)
            Rectangle().fill(AppColors.primaryOpacity(0.2)).frame(width: 1, height: 40)
            infoColumn(value: "\(info.averagePresence)%", label: AppStrings.presence)
            Rectangle().fill(AppColors.primaryOpacity(0.2)).frame(width: 1, height: 40)
            infoColumn(value: info.sala.isEmpty ? "—" : info.sala, label: "Sala")
        }
        .padding(.vertical, AppDimens.spacingXL)
        .background(
            LinearGradient(
                colors: [AppColors.primary, AppColors.purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
    }

    private func infoColumn(value: String, label: String) -> some View {
        VStack(spacing: AppDimens.spacingXS) {
            Text(value)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    private var atRiskSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.exclamation)
                    .foregroundColor(AppColors.warning)
                Text("\(AppStrings.atRisk) — \(AppStrings.belowMinimum)")
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(viewModel.atRisk) { student in
                HStack(spacing: AppDimens.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(AppColors.warning.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text(initials(student.name))
                            .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                            .foregroundColor(AppColors.warning)
                    }

                    Text(student.name)
                        .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    Text("\(student.presencePercentage)%")
                        .font(.system(size: AppDimens.fontSmall, weight: .bold))
                        .foregroundColor(AppColors.error)
                }
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.warning.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .overlay(
            RoundedRectangle(cornerRadius: AppDimens.radiusLG)
                .stroke(AppColors.warning.opacity(0.2), lineWidth: 1)
        )
    }

    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.studentsList)
                .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            if viewModel.alunos.isEmpty && !viewModel.isLoading {
                Text("Nenhum aluno matriculado nesta turma.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            } else {
                ForEach(viewModel.alunos) { student in
                    HStack(spacing: AppDimens.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primaryOpacity(0.12))
                                .frame(width: 36, height: 36)
                            Text(initials(student.name))
                                .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(student.name)
                                .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text(student.matricula)
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        Text("\(student.presencePercentage)%")
                            .font(.system(size: AppDimens.fontSmall, weight: .bold))
                            .foregroundColor(student.presencePercentage < 75 ? AppColors.error : AppColors.success)
                    }
                    .padding(AppDimens.spacingMD)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
                }
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.attendanceHistory)
                .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            if viewModel.historico.isEmpty && !viewModel.isLoading {
                Text("Sem chamadas ainda nesta turma.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            } else {
                ForEach(viewModel.historico) { attendance in
                    HStack {
                        VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                            Text("\(attendance.date) • \(attendance.time)")
                                .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text(attendance.classType ?? "")
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Text("\(attendance.presentCount)/\(attendance.totalCount)")
                            .font(.system(size: AppDimens.fontSmall, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(AppDimens.spacingLG)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
                }
            }
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(f)\(l)".uppercased()
    }
}

#Preview {
    NavigationStack {
        ClassDetailView(turma: TurmaDTO(
            id: 1,
            nome: "Programação Web",
            codigo: "CC401",
            sala: "Lab 101",
            horarioSemanal: "Seg/Qua 10:00",
            totalStudents: 35,
            averagePresence: 91,
            studentsAtRisk: 2
        ))
    }
}
