//
//  SplashView.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.splashGradientTop, AppColors.splashGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: AppDimens.spacingLG) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppDimens.radiusXL)
                        .fill(.white)
                        .frame(width: AppDimens.splashLogoSize, height: AppDimens.splashLogoSize)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                    Image(systemName: AppIcons.qrCode)
                        .font(.system(size: AppDimens.icon3XL, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.splashGradientTop, AppColors.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: AppDimens.spacingSM) {
                    Text(AppStrings.appName)
                        .font(.system(size: AppDimens.fontSplash, weight: .bold))
                        .foregroundColor(.white)

                    Text(AppStrings.appSubtitle)
                        .font(.system(size: AppDimens.fontSubhead, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                textOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isActive = false
                }
            }
        }
    }
}
