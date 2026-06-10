//
//  CoordenacaoProfileView.swift
//  QRollCall
//

import SwiftUI

struct CoordenacaoProfileView: View {
    @EnvironmentObject private var auth: AuthSession

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppDimens.spacingXL) {
                    header
                    settingsList
                    logoutButton
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.tabProfile)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: auth.initials, size: 80)

            Text(auth.fullName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
            Text(auth.email)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
            Text(AppStrings.coordHomeGreeting.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColors.primaryStrong)
                .tracking(0.5)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppColors.surfaceMuted, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(AppColors.hairline, lineWidth: 0.5)
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppDimens.spacingLG)
    }

    private var settingsList: some View {
        VStack(spacing: 0) {
            settingsRow(icon: AppIcons.bell, label: AppStrings.notifications)
            divider
            settingsRow(icon: AppIcons.shield, label: AppStrings.privacyLGPD)
            divider
            settingsRow(icon: AppIcons.questionCircle, label: AppStrings.helpSupport)
        }
        .background(AppColors.cardBackground,
                    in: RoundedRectangle(cornerRadius: AppDimens.radiusMD, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func settingsRow(icon: String, label: String) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.primary)
                .frame(width: 28)
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, AppDimens.spacingLG)
        .padding(.vertical, AppDimens.spacingLG)
        .contentShape(Rectangle())
    }

    private var divider: some View {
        Divider()
            .padding(.leading, AppDimens.spacingLG + 28 + AppDimens.spacingMD)
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
            .background(AppColors.error.opacity(0.10),
                        in: RoundedRectangle(cornerRadius: AppDimens.radiusMD, style: .continuous))
            .foregroundStyle(AppColors.error)
        }
    }
}

#Preview {
    CoordenacaoProfileView()
        .environmentObject(AuthSession.shared)
}
