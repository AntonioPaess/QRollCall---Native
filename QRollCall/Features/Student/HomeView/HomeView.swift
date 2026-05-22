//
//  HomeView.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

struct HomeView: View {
    @State private var showAttendanceFlow = false
    @State private var hasActiveAttendance = true

    private let user = MockData.user
    private let nextClass = MockData.nextClass
    private let stats = MockData.stats
    private let activities = MockData.recentActivities

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background)
        .fullScreenCover(isPresented: $showAttendanceFlow) {
            AttendanceFlowView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        LinearGradient(
            colors: AppColors.headerGradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(height: 160)
        .overlay(alignment: .bottomLeading) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(AppStrings.greeting)
                        .font(.system(size: AppDimens.fontCallout, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                    Text(user.fullName)
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: AppDimens.avatarSize, height: AppDimens.avatarSize)
                    Text(user.initials)
                        .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.bottom, AppDimens.spacingXL)
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: AppDimens.spacingXL) {
            if hasActiveAttendance {
                activeAttendanceBanner
            }
            nextClassCard
            statsGrid
            recentActivitySection
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .padding(.bottom, AppDimens.spacingXXL)
    }

    // MARK: - Active Attendance Banner

    private var activeAttendanceBanner: some View {
        Button {
            showAttendanceFlow = true
        } label: {
            HStack(spacing: AppDimens.spacingLG) {
                ZStack {
                    Circle()
                        .fill(AppColors.success.opacity(0.15))
                        .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
                    Image(systemName: AppIcons.checkCircleFill)
                        .font(.system(size: AppDimens.iconLG))
                        .foregroundColor(AppColors.success)
                }

                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(AppStrings.activeAttendance)
                        .font(.system(size: AppDimens.fontCallout, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(AppStrings.tapToRegister)
                        .font(.system(size: AppDimens.fontCaption, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: AppDimens.iconSM, weight: .semibold))
                    .foregroundColor(AppColors.success)
            }
            .padding(AppDimens.spacingLG)
            .background(AppColors.success.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
            .overlay(
                RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                    .stroke(AppColors.success.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Next Class Card

    private var nextClassCard: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.clock)
                    .font(.system(size: AppDimens.iconMD))
                    .foregroundColor(AppColors.primary)
                Text(AppStrings.nextClass)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(nextClass.name)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text("\(nextClass.startTime) - \(nextClass.endTime) • \(nextClass.room)")
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(AppColors.textSecondary)

            HStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.primaryOpacity(0.15))
                            .frame(height: AppDimens.progressBarHeight)
                        Capsule()
                            .fill(AppColors.primary)
                            .frame(width: geometry.size.width * nextClass.progress, height: AppDimens.progressBarHeight)
                    }
                }
                .frame(height: AppDimens.progressBarHeight)

                Text(nextClass.timeUntil)
                    .font(.system(size: AppDimens.fontCaption, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .fixedSize()
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: AppDimens.spacingMD), GridItem(.flexible(), spacing: AppDimens.spacingMD)], spacing: AppDimens.spacingMD) {
            StatCard(
                icon: AppIcons.chartUp,
                iconColor: AppColors.success,
                title: AppStrings.presence,
                value: "\(stats.presencePercentage)%",
                subtitle: stats.presenceChange,
                subtitleColor: AppColors.success
            )
            StatCard(
                icon: AppIcons.checkCircle,
                iconColor: AppColors.primary,
                title: AppStrings.classes,
                value: "\(stats.totalClasses)",
                subtitle: AppStrings.confirmed,
                subtitleColor: AppColors.textSecondary
            )
            StatCard(
                icon: AppIcons.xCircle,
                iconColor: AppColors.error,
                title: AppStrings.absences,
                value: "\(stats.absences)",
                subtitle: AppStrings.thisSemester,
                subtitleColor: AppColors.textSecondary
            )
            StatCard(
                icon: AppIcons.flame,
                iconColor: AppColors.warning,
                title: AppStrings.streak,
                value: "\(stats.streakDays)",
                subtitle: AppStrings.consecutiveDays,
                subtitleColor: AppColors.textSecondary
            )
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.recentActivity)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            ForEach(activities) { activity in
                ActivityRow(activity: activity)
            }
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    let subtitleColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingSM) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: AppDimens.fontSmall, weight: .medium))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: AppDimens.fontSmall, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }

            Text(value)
                .font(.system(size: AppDimens.fontHero, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(subtitle)
                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                .foregroundColor(subtitleColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingLG)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let activity: RecentActivity

    private var statusColor: Color {
        switch activity.status {
        case .presente: return AppColors.success
        case .ausente: return AppColors.error
        case .justificado: return AppColors.warning
        }
    }

    var body: some View {
        HStack(spacing: AppDimens.spacingSM + 6) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
                Image(systemName: activity.status == .presente ? AppIcons.checkCircleFill : AppIcons.xCircleFill)
                    .font(.system(size: AppDimens.iconLG))
                    .foregroundColor(statusColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.className)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text("\(activity.date) • \(activity.time)")
                    .font(.system(size: AppDimens.fontCaption, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text(activity.status.rawValue)
                .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, AppDimens.spacingMD)
                .padding(.vertical, 6)
                .background(statusColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(AppDimens.spacingLG)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    HomeView()
}
