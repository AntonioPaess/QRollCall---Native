//
//  AttendanceSummaryView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct AttendanceSummaryView: View {
    @Environment(\.dismiss) private var dismiss

    let className: String
    let classType: ClassType
    let presentStudents: [StudentAttendanceRecord]
    let absentStudents: [StudentAttendanceRecord]
    let totalStudents: Int

    private var presencePercentage: Int {
        guard totalStudents > 0 else { return 0 }
        return Int(round(Double(presentStudents.count) / Double(totalStudents) * 100))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppDimens.spacingXL) {
                    summaryHeader
                    presentSection
                    absentSection
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

    // MARK: - Summary Header

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
                summaryColumn(value: "\(absentStudents.count)", label: AppStrings.absentStudents, color: AppColors.error)
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

    // MARK: - Present Section

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

            ForEach(presentStudents) { student in
                studentRow(student: student, isPresent: true)
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
    }

    // MARK: - Absent Section

    private var absentSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.xCircleFill)
                    .foregroundColor(AppColors.error)
                Text(AppStrings.absentStudents)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(absentStudents.count)")
                    .font(.system(size: AppDimens.fontCallout, weight: .bold))
                    .foregroundColor(AppColors.error)
            }

            ForEach(absentStudents) { student in
                studentRow(student: student, isPresent: false)
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
    }

    private func studentRow(student: StudentAttendanceRecord, isPresent: Bool) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            ZStack {
                Circle()
                    .fill((isPresent ? AppColors.success : AppColors.error).opacity(0.12))
                    .frame(width: 36, height: 36)
                Text(student.initials)
                    .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                    .foregroundColor(isPresent ? AppColors.success : AppColors.error)
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

            if isPresent, let time = student.confirmedAt {
                Text(time)
                    .font(.system(size: AppDimens.fontCaption, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Conclude

    private var concludeButton: some View {
        Button {
            NotificationCenter.default.post(name: .dismissAttendanceFlow, object: nil)
        } label: {
            Text(AppStrings.conclude)
                .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppDimens.buttonHeight)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AttendanceSummaryView(
        className: "Programação Web",
        classType: .first,
        presentStudents: Array(ProfessorHomeMockData.studentsForClass.prefix(5)),
        absentStudents: Array(ProfessorHomeMockData.studentsForClass.suffix(3)),
        totalStudents: 35
    )
}
