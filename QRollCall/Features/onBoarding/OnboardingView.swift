//
//  OnboardingView.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSplash = true
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: AppIcons.qrScanner,
            iconColor: AppColors.primary,
            title: AppStrings.onboardingQRTitle,
            description: AppStrings.onboardingQRDescription
        ),
        OnboardingPage(
            icon: AppIcons.faceId,
            iconColor: AppColors.purple,
            title: AppStrings.onboardingFaceTitle,
            description: AppStrings.onboardingFaceDescription
        ),
        OnboardingPage(
            icon: AppIcons.location,
            iconColor: AppColors.green,
            title: AppStrings.onboardingLocationTitle,
            description: AppStrings.onboardingLocationDescription
        )
    ]

    var body: some View {
        if showSplash {
            SplashView(isActive: $showSplash)
                .transition(.opacity)
        } else {
            onboardingContent
                .transition(.opacity)
        }
    }

    // MARK: - Onboarding Content

    private var onboardingContent: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(AppStrings.skip) {
                    completeOnboarding()
                }
                .font(.system(size: AppDimens.fontSubhead, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .padding(.trailing, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingSM)
            }

            Spacer()

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            Spacer()

            HStack(spacing: AppDimens.spacingSM) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? pages[currentPage].iconColor : Color.gray.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.25), value: currentPage)
                }
            }
            .padding(.bottom, AppDimens.spacingXXXL)

            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            }) {
                HStack(spacing: AppDimens.spacingSM) {
                    Text(currentPage < pages.count - 1 ? AppStrings.continueButton : AppStrings.startButton)
                        .font(.system(size: AppDimens.fontTitle3, weight: .semibold))

                    Image(systemName: AppIcons.chevronRight)
                        .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppDimens.buttonHeight)
                .background(pages[currentPage].iconColor)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.bottom, AppDimens.spacing4XL)
            .animation(.easeInOut(duration: 0.25), value: currentPage)
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppDimens.spacingXXL) {
            ZStack {
                RoundedRectangle(cornerRadius: AppDimens.radiusXXL)
                    .fill(page.iconColor)
                    .frame(width: AppDimens.onboardingIconSize, height: AppDimens.onboardingIconSize)
                    .shadow(color: page.iconColor.opacity(0.3), radius: 15, y: 8)

                Image(systemName: page.icon)
                    .font(.system(size: AppDimens.icon4XL, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.bottom, AppDimens.spacingSM)

            Text(page.title)
                .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.textPrimary)

            Text(page.description)
                .font(.system(size: AppDimens.fontCallout, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
                .padding(.horizontal, AppDimens.spacing4XL)
        }
        .padding(.horizontal, AppDimens.spacingXXL)
    }
}

#Preview {
    OnboardingView()
}
