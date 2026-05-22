//
//  ProfileView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    private let user = ProfileMockData.user
    private let stats = ProfileMockData.stats
    private let settingsItems = ProfileMockData.settingsItems

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background)
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: AppColors.headerGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 140)

            VStack {
                HStack {
                    Text(AppStrings.profileTitle)
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.bottom, AppDimens.spacingXXXL)
            }

            profileCard
                .offset(y: 130)
        }
        .padding(.bottom, 140)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(spacing: AppDimens.spacingXL) {
            HStack(spacing: AppDimens.spacingLG) {
                ZStack(alignment: .bottomLeading) {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Text(user.initials)
                                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                                .foregroundColor(.white)
                        )

                    ZStack {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 26, height: 26)
                        Image(systemName: AppIcons.camera)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .offset(x: -2, y: 2)
                }

                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(user.fullName)
                        .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(AppStrings.matricula) \(user.matricula)")
                        .font(.system(size: AppDimens.fontSmall, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }

            VStack(spacing: AppDimens.spacingMD) {
                ProfileInfoRow(icon: AppIcons.envelope, text: user.email)
                ProfileInfoRow(icon: AppIcons.phone, text: user.phone)
                ProfileInfoRow(icon: AppIcons.graduationCap, text: user.courseInfo)
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        .padding(.horizontal, AppDimens.spacingXXL)
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: AppDimens.spacingXL) {
//            facialUpdateCard
            statsSection
            settingsSection
            logoutButton
            versionFooter
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .padding(.bottom, AppDimens.spacingXXL)
    }

    // MARK: - Facial Update Card

//    private var facialUpdateCard: some View {
//        Button(action: {}) {
//            HStack(spacing: AppDimens.spacingLG) {
//                ZStack {
//                    Circle()
//                        .fill(AppColors.primaryOpacity(0.12))
//                        .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
//                    Image(systemName: AppIcons.facialUpdate)
//                        .font(.system(size: AppDimens.iconLG))
//                        .foregroundColor(AppColors.primary)
//                }
//
//                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
//                    Text(AppStrings.updateFacialRegistration)
//                        .font(.system(size: AppDimens.fontCallout, weight: .semibold))
//                        .foregroundColor(AppColors.textPrimary)
//                    Text("\(AppStrings.lastUpdate) \(user.facialUpdateDate)")
//                        .font(.system(size: AppDimens.fontCaption, weight: .regular))
//                        .foregroundColor(AppColors.textSecondary)
//                }
//
//                Spacer()
//
//                Image(systemName: AppIcons.chevronRight)
//                    .font(.system(size: AppDimens.iconSM, weight: .medium))
//                    .foregroundColor(AppColors.textTertiary)
//            }
//            .padding(AppDimens.spacingLG)
//            .background(AppColors.cardBackground)
//            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
//            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
//        }
//        .buttonStyle(.plain)
//    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.statsIcon)
                    .font(.system(size: AppDimens.iconMD))
                    .foregroundColor(AppColors.primary)
                Text(AppStrings.generalStats)
                    .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: AppDimens.spacingMD),
                    GridItem(.flexible(), spacing: AppDimens.spacingMD)
                ],
                spacing: AppDimens.spacingMD
            ) {
                ProfileStatCell(value: "\(stats.presenceRate)%", label: AppStrings.presenceRate)
                ProfileStatCell(value: "\(stats.confirmedClasses)", label: AppStrings.confirmedClasses)
                ProfileStatCell(value: "\(stats.absences)", label: AppStrings.absences)
                ProfileStatCell(value: "\(stats.consecutiveDays)", label: AppStrings.consecutiveDaysProfile)
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(AppStrings.settings)
                .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, AppDimens.spacingXL)
                .padding(.top, AppDimens.spacingXL)
                .padding(.bottom, AppDimens.spacingLG)

            ForEach(Array(settingsItems.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider()
                        .padding(.horizontal, AppDimens.spacingXL)
                }

                Button(action: {}) {
                    HStack(spacing: AppDimens.spacingLG) {
                        Image(systemName: item.icon)
                            .font(.system(size: AppDimens.iconLG, weight: .regular))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: AppDimens.iconXL)

                        Text(item.title)
                            .font(.system(size: AppDimens.fontCallout, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Image(systemName: AppIcons.chevronRight)
                            .font(.system(size: AppDimens.iconSM, weight: .medium))
                            .foregroundColor(AppColors.textTertiary)
                    }
                    .padding(.horizontal, AppDimens.spacingXL)
                    .padding(.vertical, AppDimens.spacingLG)
                }
                .buttonStyle(.plain)
            }
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            isLoggedIn = false
        } label: {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.logout)
                    .font(.system(size: AppDimens.iconMD, weight: .medium))
                Text(AppStrings.logout)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
            }
            .foregroundColor(AppColors.error)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppDimens.spacingLG)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Version Footer

    private var versionFooter: some View {
        Text(AppStrings.appVersion)
            .font(.system(size: AppDimens.fontCaption, weight: .regular))
            .foregroundColor(AppColors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.top, AppDimens.spacingSM)
    }
}

// MARK: - Profile Info Row

private struct ProfileInfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: AppDimens.iconMD, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .frame(width: AppDimens.iconXL)

            Text(text)
                .font(.system(size: AppDimens.fontSmall, weight: .regular))
                .foregroundColor(AppColors.textSecondary)

            Spacer()
        }
    }
}

// MARK: - Profile Stat Cell

private struct ProfileStatCell: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingSM) {
            Text(value)
                .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingLG)
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
    }
}

#Preview {
    ProfileView()
}
