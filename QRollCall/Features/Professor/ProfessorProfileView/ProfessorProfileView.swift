//
//  ProfessorProfileView.swift
//  QRollCall
//

import SwiftUI

struct ProfessorProfileView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var viewModel = ProfessorProfileViewModel()

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

    private var header: some View {
        ProfileHeader(
            initials: viewModel.initials,
            fullName: viewModel.fullName,
            roleLabel: "Professor",
            infoLines: profileInfoLines
        )
    }

    private var profileInfoLines: [ProfileHeader.InfoLine] {
        var lines: [ProfileHeader.InfoLine] = []
        if let dep = viewModel.perfil?.department, !dep.isEmpty {
            lines.append(.init(icon: AppIcons.book, text: dep))
        }
        lines.append(.init(icon: AppIcons.envelope, text: viewModel.perfil?.email ?? "—"))
        if let phone = viewModel.perfil?.phone, !phone.isEmpty {
            lines.append(.init(icon: AppIcons.phone, text: phone))
        }
        return lines
    }

    private var statsSection: some View {
        let p = viewModel.perfil
        return VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: AppStrings.generalStats)
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppDimens.spacingMD),
                          GridItem(.flexible(), spacing: AppDimens.spacingMD)],
                spacing: AppDimens.spacingMD
            ) {
                KPICard(title: AppStrings.averagePresence,
                        value: "\(p?.averagePresence ?? 0)%",
                        icon: AppIcons.chartUp,
                        tint: AppColors.success)
                KPICard(title: AppStrings.classesGiven,
                        value: "\(p?.classesGiven ?? 0)",
                        icon: AppIcons.doc,
                        tint: AppColors.primary)
                KPICard(title: AppStrings.tabClasses,
                        value: "\(p?.activeClasses ?? 0)",
                        icon: AppIcons.classes,
                        tint: AppColors.primaryStrong)
                KPICard(title: "Alunos",
                        value: "\(p?.totalStudents ?? 0)",
                        icon: AppIcons.people,
                        tint: AppColors.purple)
            }
        }
    }

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
    ProfessorProfileView()
        .environmentObject(AuthSession.shared)
}
