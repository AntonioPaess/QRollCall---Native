//
//  HomeView.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var viewModel = StudentHomeViewModel()
    @State private var selectedAttendance: ChamadaAtivaDTO?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
        .fullScreenCover(item: $selectedAttendance, onDismiss: {
            Task { await viewModel.load() }
        }) { attendance in
            AttendanceFlowView(attendance: attendance)
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
                    Text(auth.fullName)
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: AppDimens.avatarSize, height: AppDimens.avatarSize)
                    Text(auth.initials.isEmpty ? "?" : auth.initials)
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
            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.error)
            }
            if let active = viewModel.firstActiveAttendance {
                activeAttendanceBanner(active)
            }
            nextClassCard
            statsGrid
            recentActivitySection
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .padding(.top, AppDimens.spacingXL)
        .padding(.bottom, AppDimens.spacingXXL)
    }

    // MARK: - Active Attendance Banner

    private func activeAttendanceBanner(_ active: ChamadaAtivaDTO) -> some View {
        Button {
            selectedAttendance = active
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
                    Text(active.materiaNome.isEmpty ? AppStrings.activeAttendance : active.materiaNome)
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

            if let next = viewModel.nextClass {
                Text(next.nome)
                    .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(next.startTime) - \(next.endTime) • \(next.sala)")
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
                                .frame(width: geometry.size.width * next.progress, height: AppDimens.progressBarHeight)
                        }
                    }
                    .frame(height: AppDimens.progressBarHeight)

                    Text(next.timeUntil)
                        .font(.system(size: AppDimens.fontCaption, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize()
                }
            } else {
                Text("Sem aulas agendadas")
                    .font(.system(size: AppDimens.fontBody, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        let s = viewModel.stats
        return LazyVGrid(columns: [GridItem(.flexible(), spacing: AppDimens.spacingMD), GridItem(.flexible(), spacing: AppDimens.spacingMD)], spacing: AppDimens.spacingMD) {
            StatCard(
                icon: AppIcons.chartUp,
                iconColor: AppColors.success,
                title: AppStrings.presence,
                value: "\(s?.presencePercentage ?? 0)%",
                subtitle: s?.presenceChange ?? "—",
                subtitleColor: AppColors.success
            )
            StatCard(
                icon: AppIcons.checkCircle,
                iconColor: AppColors.primary,
                title: AppStrings.classes,
                value: "\(s?.totalClasses ?? 0)",
                subtitle: AppStrings.confirmed,
                subtitleColor: AppColors.textSecondary
            )
            StatCard(
                icon: AppIcons.xCircle,
                iconColor: AppColors.error,
                title: AppStrings.absences,
                value: "\(s?.absences ?? 0)",
                subtitle: AppStrings.thisSemester,
                subtitleColor: AppColors.textSecondary
            )
            StatCard(
                icon: AppIcons.flame,
                iconColor: AppColors.warning,
                title: AppStrings.streak,
                value: "\(s?.streakDays ?? 0)",
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

            if viewModel.activities.isEmpty && !viewModel.isLoading {
                Text("Sem atividades por aqui ainda.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            } else {
                ForEach(viewModel.activities) { activity in
                    ActivityRow(activity: activity)
                }
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
    let activity: AtividadeDTO

    private var statusColor: Color {
        switch activity.status.lowercased() {
        case "presente": return AppColors.success
        case "ausente": return AppColors.error
        default: return AppColors.warning
        }
    }

    var body: some View {
        HStack(spacing: AppDimens.spacingSM + 6) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
                Image(systemName: activity.status.lowercased() == "presente" ? AppIcons.checkCircleFill : AppIcons.xCircleFill)
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

            Text(activity.status)
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
    HomeView().environmentObject(AuthSession.shared)
}
