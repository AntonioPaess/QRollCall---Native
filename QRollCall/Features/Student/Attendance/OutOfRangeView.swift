//
//  OutOfRangeView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct OutOfRangeView: View {
    let onRetry: () -> Void

    @State private var iconScale: CGFloat = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppDimens.spacingXXXL) {
                Spacer()

                iconSection
                textSection

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
        }
    }

    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(AppColors.error.opacity(0.1))
                .frame(width: 120, height: 120)
            Circle()
                .fill(AppColors.error.opacity(0.18))
                .frame(width: 90, height: 90)
            Image(systemName: AppIcons.bluetoothOff)
                .font(.system(size: 40, weight: .medium))
                .foregroundColor(AppColors.error)
        }
        .scaleEffect(iconScale)
    }

    private var textSection: some View {
        VStack(spacing: AppDimens.spacingMD) {
            Text(AppStrings.outOfRangeTitle)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            Text(AppStrings.outOfRangeMessage)
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .opacity(contentOpacity)
    }

    private var retryButton: some View {
        Button {
            onRetry()
        } label: {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.bluetoothOn)
                    .font(.system(size: AppDimens.iconMD))
                Text(AppStrings.tryAgain)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .opacity(contentOpacity)
        .padding(.bottom, AppDimens.spacing4XL)
    }
}

#Preview {
    OutOfRangeView {}
}
