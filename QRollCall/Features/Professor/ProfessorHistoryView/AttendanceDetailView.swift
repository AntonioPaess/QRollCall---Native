//
//  AttendanceDetailView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct AttendanceDetailView: View {
    let attendance: ChamadaPassadaDTO
    @StateObject private var viewModel = AttendanceDetailViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppDimens.spacingXL) {
                infoCard

                if let msg = viewModel.errorMessage {
                    Text(msg)
                        .font(.system(size: AppDimens.fontCaption))
                        .foregroundColor(AppColors.error)
                }

                studentSection(
                    title: AppStrings.presentStudents,
                    icon: AppIcons.checkCircleFill,
                    color: AppColors.success,
                    students: viewModel.detalhe?.presentes ?? []
                )

                studentSection(
                    title: AppStrings.absentStudents,
                    icon: AppIcons.xCircleFill,
                    color: AppColors.error,
                    students: viewModel.detalhe?.ausentes ?? []
                )
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.vertical, AppDimens.spacingLG)
        }
        .background(AppColors.background)
        .navigationTitle(AppStrings.attendanceDetail)
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load(chamadaId: attendance.id) }
        .refreshable { await viewModel.load(chamadaId: attendance.id) }
    }

    private var infoCard: some View {
        let presentes = viewModel.detalhe?.presentes.count ?? attendance.presentCount
        let ausentes = viewModel.detalhe?.ausentes.count ?? (attendance.totalCount - attendance.presentCount)
        return VStack(spacing: AppDimens.spacingMD) {
            Text(viewModel.detalhe?.className ?? attendance.className)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(.white)

            Text("\(viewModel.detalhe?.date ?? attendance.date) • \(viewModel.detalhe?.time ?? attendance.time)")
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(.white.opacity(0.8))

            if let type = viewModel.detalhe?.classType ?? attendance.classType {
                Text(type)
                    .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, AppDimens.spacingMD)
                    .padding(.vertical, AppDimens.spacingXS)
                    .background(.white.opacity(0.2))
                    .clipShape(Capsule())
            }

            HStack(spacing: AppDimens.spacingXXXL) {
                VStack(spacing: AppDimens.spacingXS) {
                    Text("\(presentes)")
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(AppColors.success)
                    Text(AppStrings.presentStudents)
                        .font(.system(size: AppDimens.fontCaption))
                        .foregroundColor(.white.opacity(0.8))
                }
                VStack(spacing: AppDimens.spacingXS) {
                    Text("\(ausentes)")
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(AppColors.error)
                    Text(AppStrings.absentStudents)
                        .font(.system(size: AppDimens.fontCaption))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.top, AppDimens.spacingSM)
        }
        .padding(AppDimens.spacingXXL)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppColors.primary, AppColors.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
    }

    private func studentSection(title: String, icon: String, color: Color, students: [ChamadaDetalheDTO.AlunoStatusDTO]) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(students.count)")
                    .font(.system(size: AppDimens.fontCallout, weight: .bold))
                    .foregroundColor(color)
            }

            if students.isEmpty && !viewModel.isLoading {
                Text("—")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            }

            ForEach(students) { student in
                HStack(spacing: AppDimens.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text(initials(student.name))
                            .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                            .foregroundColor(color)
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

                    if let confirmed = student.confirmedAt, !confirmed.isEmpty {
                        Text(confirmed)
                            .font(.system(size: AppDimens.fontCaption, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(AppDimens.spacingMD)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
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
        AttendanceDetailView(attendance: ChamadaPassadaDTO(
            id: 1,
            className: "Programação Web",
            date: "Hoje",
            time: "10:00",
            presentCount: 32,
            totalCount: 35,
            presencePercentage: 91,
            classType: "PRIMEIRA"
        ))
    }
}
