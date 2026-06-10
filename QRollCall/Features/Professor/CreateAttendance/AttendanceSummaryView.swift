//
//  AttendanceSummaryView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct AttendanceSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    let chamada: ChamadaCreatedDTO
    let className: String
    let classType: ClassType
    let presentStudents: [LiveAttendanceDTO.ConfirmadoDTO]
    let totalStudents: Int

    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var presencePercentage: Int {
        guard totalStudents > 0 else { return 0 }
        return Int(round(Double(presentStudents.count) / Double(totalStudents) * 100))
    }

    private var absentCount: Int {
        max(totalStudents - presentStudents.count, 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppDimens.spacingXL) {
                    summaryHeader
                    if let msg = errorMessage {
                        Text(msg)
                            .font(.system(size: AppDimens.fontCaption))
                            .foregroundColor(AppColors.error)
                    }
                    presentSection
                    concludeButton
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.vertical, AppDimens.spacingXL)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.summaryTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var summaryHeader: some View {
        VStack(spacing: AppDimens.spacingLG) {
            Text(className)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(classType.rawValue)
                .font(.system(size: AppDimens.fontCaption, weight: .medium))
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, AppDimens.spacingMD)
                .padding(.vertical, AppDimens.spacingXS)
                .background(AppColors.primaryOpacity(0.1))
                .clipShape(Capsule())

            HStack(spacing: 0) {
                summaryColumn(value: "\(presentStudents.count)", label: AppStrings.presentStudents, color: AppColors.success)
                Rectangle().fill(.white.opacity(0.25)).frame(width: 1, height: 40)
                summaryColumn(value: "\(absentCount)", label: AppStrings.absentStudents, color: AppColors.error)
                Rectangle().fill(.white.opacity(0.25)).frame(width: 1, height: 40)
                summaryColumn(value: "\(presencePercentage)%", label: AppStrings.rate, color: .white)
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
    }

    private func summaryColumn(value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppDimens.spacingXS) {
            Text(value)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }

    private var presentSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.checkCircleFill)
                    .foregroundColor(AppColors.success)
                Text(AppStrings.presentStudents)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(presentStudents.count)")
                    .font(.system(size: AppDimens.fontCallout, weight: .bold))
                    .foregroundColor(AppColors.success)
            }

            if presentStudents.isEmpty {
                Text("Nenhum aluno confirmou.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            }

            ForEach(presentStudents) { student in
                studentRow(student: student)
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
    }

    private func studentRow(student: LiveAttendanceDTO.ConfirmadoDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            ZStack {
                Circle()
                    .fill(AppColors.success.opacity(0.12))
                    .frame(width: 36, height: 36)
                Text(initials(student.name))
                    .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                    .foregroundColor(AppColors.success)
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

            if let time = student.confirmedAt {
                Text(time)
                    .font(.system(size: AppDimens.fontCaption, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(f)\(l)".uppercased()
    }

    private var concludeButton: some View {
        Button {
            Task { await finalize() }
        } label: {
            ZStack {
                Text(AppStrings.conclude)
                    .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isSubmitting ? 0 : 1)
                if isSubmitting {
                    ProgressView().tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .disabled(isSubmitting)
    }

    private func finalize() async {
        isSubmitting = true
        defer { isSubmitting = false }
        let presentes = presentStudents.map(\.alunoId)
        do {
            try await ChamadaService.encerrarComResumo(
                chamada.idChamada,
                resumo: EncerrarComResumoDTO(alunosPresentes: presentes, alunosAusentes: [])
            )
            NotificationCenter.default.post(name: .dismissAttendanceFlow, object: nil)
            dismiss()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Falha ao encerrar."
        }
    }
}
