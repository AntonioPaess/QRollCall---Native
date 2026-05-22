//
//  GamificationFailView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct GamificationFailView: View {
    let onRetry: () -> Void

    @State private var iconScale: CGFloat = 0
    @State private var contentOpacity: Double = 0
    @State private var cooldown = 30
    @State private var timer: Timer?

    private var canRetry: Bool { cooldown == 0 }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppDimens.spacingXXXL) {
                Spacer()

                iconSection
                textSection

                if !canRetry {
                    cooldownIndicator
                }

                Spacer()

                retryButton
            }
            .padding(.horizontal, AppDimens.spacingXXL)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                contentOpacity = 1.0
            }
            startCooldown()
        }
        .onDisappear { stopCooldown() }
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(AppColors.error.opacity(0.1))
                .frame(width: 120, height: 120)
            Circle()
                .fill(AppColors.error.opacity(0.18))
                .frame(width: 90, height: 90)
            Image(systemName: AppIcons.xCircleFill)
                .font(.system(size: 44, weight: .medium))
                .foregroundColor(AppColors.error)
        }
        .scaleEffect(iconScale)
    }

    private var textSection: some View {
        VStack(spacing: AppDimens.spacingMD) {
            Text(AppStrings.gamificationFailTitle)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            if !canRetry {
                Text("\(AppStrings.gamificationFailMessage) \(cooldown) \(AppStrings.seconds)")
                    .font(.system(size: AppDimens.fontBody, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .opacity(contentOpacity)
    }

    private var cooldownIndicator: some View {
        ZStack {
            Circle()
                .stroke(AppColors.textTertiary.opacity(0.3), lineWidth: 4)
                .frame(width: 64, height: 64)
            Circle()
                .trim(from: 0, to: CGFloat(cooldown) / 30.0)
                .stroke(AppColors.error, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: cooldown)
            Text("\(cooldown)")
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .opacity(contentOpacity)
    }

    private var retryButton: some View {
        Button {
            onRetry()
        } label: {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.faceId)
                    .font(.system(size: AppDimens.iconMD))
                Text(AppStrings.tryAgain)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(canRetry ? AppColors.primary : AppColors.primaryOpacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .disabled(!canRetry)
        .opacity(contentOpacity)
        .padding(.bottom, AppDimens.spacing4XL)
    }

    private func startCooldown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if cooldown > 0 { cooldown -= 1 }
            else { stopCooldown() }
        }
    }

    private func stopCooldown() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    GamificationFailView {}
}
