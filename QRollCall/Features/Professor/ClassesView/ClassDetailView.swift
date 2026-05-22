//
//  ClassDetailView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ClassDetailView: View {
    let professorClass: ProfessorClass

    private let students = ProfessorHomeMockData.studentsForClass
    private let pastAttendances = ProfessorHomeMockData.pastAttendances

    private var atRiskStudents: [StudentAttendanceRecord] {
        students.filter { $0.presencePercentage < 75 }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppDimens.spacingXL) {
                classInfoHeader
                if !atRiskStudents.isEmpty {
                    atRiskSection
                }
                studentsSection
                historySection
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.vertical, AppDimens.spacingLG)
        }
        .background(AppColors.background)
        .navigationTitle(professorClass.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Class Info

    private var classInfoHeader: some View {
        HStack(spacing: 0) {
            infoColumn(value: "\(professorClass.totalStudents)", label: AppStrings.students)
            Rectangle().fill(AppColors.primaryOpacity(0.2)).frame(width: 1, height: 40)
            infoColumn(value: "\(professorClass.averagePresence)%", label: AppStrings.presence)
            Rectangle().fill(AppColors.primaryOpacity(0.2)).frame(width: 1, height: 40)
            infoColumn(value: professorClass.room, label: "Sala")
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

    // MARK: - At Risk

    private var atRiskSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.exclamation)
                    .foregroundColor(AppColors.warning)
                Text("\(AppStrings.atRisk) — \(AppStrings.belowMinimum)")
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }

            ForEach(atRiskStudents) { student in
                HStack(spacing: AppDimens.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(AppColors.warning.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text(student.initials)
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

    // MARK: - Students List

    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.studentsList)
                .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            ForEach(students) { student in
                HStack(spacing: AppDimens.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryOpacity(0.12))
                            .frame(width: 36, height: 36)
                        Text(student.initials)
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

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.attendanceHistory)
                .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            ForEach(pastAttendances.filter { $0.className == professorClass.name }) { attendance in
                HStack {
                    VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                        Text("\(attendance.date) • \(attendance.time)")
                            .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text(attendance.classType.rawValue)
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

#Preview {
    NavigationStack {
        ClassDetailView(professorClass: ProfessorHomeMockData.classes[0])
    }
}
