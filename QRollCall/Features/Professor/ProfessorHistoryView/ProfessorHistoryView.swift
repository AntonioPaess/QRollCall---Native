//
//  ProfessorHistoryView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ProfessorHistoryView: View {
    @State private var selectedFilter = "Todas"
    private let pastAttendances = ProfessorHomeMockData.pastAttendances
    private let classes = ProfessorHomeMockData.classes

    private var filters: [String] {
        ["Todas"] + classes.map(\.name)
    }

    private var filteredAttendances: [PastAttendance] {
        if selectedFilter == "Todas" { return pastAttendances }
        return pastAttendances.filter { $0.className == selectedFilter }
    }

    private var totalPresent: Int { filteredAttendances.reduce(0) { $0 + $1.presentCount } }
    private var totalStudents: Int { filteredAttendances.reduce(0) { $0 + $1.totalCount } }
    private var averageRate: Int {
        guard totalStudents > 0 else { return 0 }
        return Int(round(Double(totalPresent) / Double(totalStudents) * 100))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                    Text(AppStrings.professorHistorySubtitle)
                        .font(.system(size: AppDimens.fontBody, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)

                    filterMenu
                    summaryCard
                    attendancesList
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.vertical, AppDimens.spacingLG)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.historyTitle)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Filter

    private var filterMenu: some View {
        Menu {
            ForEach(filters, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    HStack {
                        Text(filter)
                        if selectedFilter == filter {
                            Image(systemName: AppIcons.checkCircleFill)
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: AppIcons.filter)
                    .font(.system(size: AppDimens.iconMD, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                Text(selectedFilter)
                    .font(.system(size: AppDimens.fontCallout, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Image(systemName: AppIcons.chevronDown)
                    .font(.system(size: AppDimens.iconSM, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, AppDimens.spacingXL)
            .padding(.vertical, AppDimens.spacingLG)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        HStack(spacing: 0) {
            VStack(spacing: AppDimens.spacingXS) {
                Text("\(filteredAttendances.count)")
                    .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                    .foregroundColor(.white)
                Text(AppStrings.classesGiven)
                    .font(.system(size: AppDimens.fontCaption, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)

            Rectangle().fill(.white.opacity(0.25)).frame(width: 1, height: 40)

            VStack(spacing: AppDimens.spacingXS) {
                Text("\(averageRate)%")
                    .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                    .foregroundColor(.white)
                Text(AppStrings.averagePresence)
                    .font(.system(size: AppDimens.fontCaption, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
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
        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, y: 4)
    }

    // MARK: - List

    private var attendancesList: some View {
        VStack(spacing: AppDimens.spacingMD) {
            ForEach(filteredAttendances) { attendance in
                NavigationLink(destination: AttendanceDetailView(attendance: attendance)) {
                    HStack(spacing: AppDimens.spacingSM + 6) {
                        ZStack {
                            Circle()
                                .fill(AppColors.primaryOpacity(0.12))
                                .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
                            Image(systemName: AppIcons.doc)
                                .font(.system(size: AppDimens.iconLG))
                                .foregroundColor(AppColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(attendance.className)
                                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("\(attendance.date) • \(attendance.time) • \(attendance.classType.rawValue)")
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(attendance.presentCount)/\(attendance.totalCount)")
                                .font(.system(size: AppDimens.fontSmall, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("\(attendance.presencePercentage)%")
                                .font(.system(size: AppDimens.fontCaption, weight: .medium))
                                .foregroundColor(AppColors.success)
                        }

                        Image(systemName: AppIcons.chevronRight)
                            .font(.system(size: AppDimens.iconSM))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(AppDimens.spacingLG)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    ProfessorHistoryView()
}
