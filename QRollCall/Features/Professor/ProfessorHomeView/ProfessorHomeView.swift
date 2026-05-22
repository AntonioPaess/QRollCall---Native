//
//  ProfessorHomeView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ProfessorHomeView: View {
    @State private var showCreateAttendance = false

    private let professor = ProfessorHomeMockData.professor
    private let nextClass = ProfessorHomeMockData.nextClass
    private let stats = ProfessorHomeMockData.stats
    private let pastAttendances = ProfessorHomeMockData.pastAttendances

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background)
        .fullScreenCover(isPresented: $showCreateAttendance) {
            CreateAttendanceView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissAttendanceFlow)) { _ in
            showCreateAttendance = false
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: AppColors.headerGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: AppDimens.headerHeight)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(AppStrings.greeting)
                        .font(.system(size: AppDimens.fontCallout, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                    Text("Prof. \(professor.firstName)")
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: AppDimens.avatarSize, height: AppDimens.avatarSize)
                    Text(professor.initials)
                        .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.bottom, 70)

            startAttendanceCard
                .offset(y: 45)
        }
        .padding(.bottom, 55)
    }

    // MARK: - Start Attendance Card

    private var startAttendanceCard: some View {
        Button {
            showCreateAttendance = true
        } label: {
            HStack(spacing: AppDimens.spacingLG) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                        .fill(AppColors.primaryOpacity(0.12))
                        .frame(width: AppDimens.qrIconContainerSize, height: AppDimens.qrIconContainerSize)
                    Image(systemName: AppIcons.play)
                        .font(.system(size: AppDimens.iconXXL, weight: .medium))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(AppStrings.startAttendance)
                        .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(AppStrings.startAttendanceSubtitle)
                        .font(.system(size: AppDimens.fontSmall, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: AppDimens.iconXL))
                    .foregroundColor(AppColors.primaryOpacity(0.5))
            }
            .padding(AppDimens.spacingXL)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppDimens.spacingXXL)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: AppDimens.spacingXL) {
            nextClassCard
            statsRow
            recentAttendancesSection
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .padding(.bottom, AppDimens.spacingXXL)
    }

    // MARK: - Next Class Card

    private var nextClassCard: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.clock)
                    .font(.system(size: AppDimens.iconMD))
                    .foregroundColor(AppColors.primary)
                Text(AppStrings.currentClass)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(nextClass.name)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text("\(nextClass.startTime) - \(nextClass.endTime) • \(nextClass.room)")
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(AppColors.textSecondary)

            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.people)
                    .font(.system(size: AppDimens.iconSM))
                    .foregroundColor(AppColors.primary)
                Text("\(nextClass.totalStudents) \(AppStrings.students)")
                    .font(.system(size: AppDimens.fontCaption, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppDimens.spacingMD) {
            StatCard(
                icon: AppIcons.chartUp,
                iconColor: AppColors.success,
                title: AppStrings.averagePresence,
                value: "\(stats.averagePresence)%",
                subtitle: "+2% este mês",
                subtitleColor: AppColors.success
            )
            StatCard(
                icon: AppIcons.doc,
                iconColor: AppColors.primary,
                title: AppStrings.classesGiven,
                value: "\(stats.classesGiven)",
                subtitle: AppStrings.thisSemester,
                subtitleColor: AppColors.textSecondary
            )
        }
    }

    // MARK: - Recent Attendances

    private var recentAttendancesSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.lastAttendances)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            ForEach(pastAttendances) { attendance in
                PastAttendanceRow(attendance: attendance)
            }
        }
    }
}

// MARK: - Past Attendance Row

private struct PastAttendanceRow: View {
    let attendance: PastAttendance

    var body: some View {
        HStack(spacing: AppDimens.spacingSM + 6) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryOpacity(0.12))
                    .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
                Image(systemName: AppIcons.checkCircleFill)
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
        }
        .padding(AppDimens.spacingLG)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    ProfessorHomeView()
}
