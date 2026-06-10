//
//  ProfileView.swift
//  QRollCall
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var viewModel = StudentProfileViewModel()

    private let settingsItems = ProfileMockData.settingsItems

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppDimens.spacingXL) {
                    header
                    statsSection
                    settingsSection
                    logoutButton
                    versionFooter
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.profileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    // MARK: - Header

    private var header: some View {
        ProfileHeader(
            initials: viewModel.initials,
            fullName: viewModel.fullName,
            roleLabel: "Aluno",
            infoLines: profileInfoLines
        )
    }

    private var profileInfoLines: [ProfileHeader.InfoLine] {
        var lines: [ProfileHeader.InfoLine] = []
        if let mat = viewModel.perfil?.matricula, !mat.isEmpty {
            lines.append(.init(icon: AppIcons.graduationCap, text: "Matrícula \(mat)"))
        }
        lines.append(.init(icon: AppIcons.envelope, text: viewModel.perfil?.email ?? "—"))
        if let phone = viewModel.perfil?.phone, !phone.isEmpty {
            lines.append(.init(icon: AppIcons.phone, text: phone))
        }
        if !viewModel.courseInfo.isEmpty {
            lines.append(.init(icon: AppIcons.book, text: viewModel.courseInfo))
        }
        return lines
    }

    // MARK: - Stats

    private var statsSection: some View {
        let s = viewModel.stats
        return VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: AppStrings.generalStats)
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppDimens.spacingMD),
                          GridItem(.flexible(), spacing: AppDimens.spacingMD)],
                spacing: AppDimens.spacingMD
            ) {
                KPICard(title: AppStrings.presenceRate,
                        value: "\(s?.presencePercentage ?? 0)%",
                        icon: AppIcons.chartUp,
                        tint: AppColors.success)
                KPICard(title: AppStrings.confirmedClasses,
                        value: "\(s?.totalClasses ?? 0)",
                        icon: AppIcons.checkCircle,
                        tint: AppColors.primary)
                KPICard(title: AppStrings.absences,
                        value: "\(s?.absences ?? 0)",
                        icon: AppIcons.xCircle,
                        tint: AppColors.danger)
                KPICard(title: AppStrings.consecutiveDaysProfile,
                        value: "\(s?.streakDays ?? 0)",
                        icon: AppIcons.flame,
                        tint: AppColors.warning)
            }
        }
    }

    // MARK: - Settings

    private var settingsSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(settingsItems.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider().padding(.leading, AppDimens.spacingLG + 28 + AppDimens.spacingMD)
                }
                settingsRow(icon: item.icon, label: item.title)
            }
        }
        .minimalCard()
    }

    private func settingsRow(icon: String, label: String) -> some View {
        Button { } label: {
            HStack(spacing: AppDimens.spacingMD) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 28)
                Text(label)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, AppDimens.spacingLG)
            .padding(.vertical, AppDimens.spacingLG)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            auth.logout()
        } label: {
            HStack {
                Image(systemName: AppIcons.logout)
                Text(AppStrings.logout)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppDimens.spacingLG)
            .background(AppColors.danger.opacity(0.10),
                        in: RoundedRectangle(cornerRadius: AppDimens.radiusMD, style: .continuous))
            .foregroundStyle(AppColors.danger)
        }
    }

    private var versionFooter: some View {
        Text(AppStrings.appVersion)
            .font(.system(size: 12))
            .foregroundStyle(AppColors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, AppDimens.spacingSM)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthSession.shared)
}
