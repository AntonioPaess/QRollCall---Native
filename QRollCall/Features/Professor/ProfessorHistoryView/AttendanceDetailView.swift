//
//  AttendanceDetailView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct AttendanceDetailView: View {
    let attendance: PastAttendance

    @State private var presentIDs: Set<UUID>
    @State private var isEditing = false

    private let allStudents = ProfessorHomeMockData.studentsForClass

    init(attendance: PastAttendance) {
        self.attendance = attendance
        let presentSet = Set(ProfessorHomeMockData.studentsForClass.filter { $0.isPresent }.map(\.id))
        self._presentIDs = State(initialValue: presentSet)
    }

    private var presentStudents: [StudentAttendanceRecord] {
        allStudents.filter { presentIDs.contains($0.id) }
    }

    private var absentStudents: [StudentAttendanceRecord] {
        allStudents.filter { !presentIDs.contains($0.id) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppDimens.spacingXL) {
                infoCard

                studentSection(
                    title: AppStrings.presentStudents,
                    count: presentStudents.count,
                    icon: AppIcons.checkCircleFill,
                    color: AppColors.success,
                    students: presentStudents,
                    isPresent: true
                )

                studentSection(
                    title: AppStrings.absentStudents,
                    count: absentStudents.count,
                    icon: AppIcons.xCircleFill,
                    color: AppColors.error,
                    students: absentStudents,
                    isPresent: false
                )
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.vertical, AppDimens.spacingLG)
        }
        .background(AppColors.background)
        .navigationTitle(AppStrings.attendanceDetail)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation { isEditing.toggle() }
                } label: {
                    Text(isEditing ? "Salvar" : "Editar")
                        .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(spacing: AppDimens.spacingMD) {
            Text(attendance.className)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(.white)

            Text("\(attendance.date) • \(attendance.time)")
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(.white.opacity(0.8))

            Text(attendance.classType.rawValue)
                .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, AppDimens.spacingMD)
                .padding(.vertical, AppDimens.spacingXS)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())

            HStack(spacing: AppDimens.spacingXXXL) {
                VStack(spacing: AppDimens.spacingXS) {
                    Text("\(presentStudents.count)")
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(AppColors.success)
                    Text(AppStrings.presentStudents)
                        .font(.system(size: AppDimens.fontCaption))
                        .foregroundColor(.white.opacity(0.8))
                }
                VStack(spacing: AppDimens.spacingXS) {
                    Text("\(absentStudents.count)")
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

    // MARK: - Student Section

    private func studentSection(title: String, count: Int, icon: String, color: Color, students: [StudentAttendanceRecord], isPresent: Bool) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(count)")
                    .font(.system(size: AppDimens.fontCallout, weight: .bold))
                    .foregroundColor(color)
            }

            ForEach(students) { student in
                HStack(spacing: AppDimens.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Text(student.initials)
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

                    if isEditing {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if isPresent {
                                    presentIDs.remove(student.id)
                                } else {
                                    presentIDs.insert(student.id)
                                }
                            }
                        } label: {
                            Image(systemName: isPresent ? AppIcons.xCircleFill : AppIcons.checkCircleFill)
                                .font(.system(size: AppDimens.iconLG))
                                .foregroundColor(isPresent ? AppColors.error : AppColors.success)
                        }
                    }
                }
                .padding(AppDimens.spacingMD)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AttendanceDetailView(attendance: ProfessorHomeMockData.pastAttendances[0])
    }
}
