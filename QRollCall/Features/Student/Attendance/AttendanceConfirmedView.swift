//
//  AttendanceConfirmedView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct AttendanceConfirmedView: View {
    let className: String
    let time: String
    let elapsedTime: TimeInterval
    let onDismiss: () -> Void

    @State private var checkScale: CGFloat = 0
    @State private var contentOpacity: Double = 0

    private var elapsedFormatted: String {
        String(format: "%.1fs", elapsedTime)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppDimens.spacingXXXL) {
                Spacer()

                checkmarkIcon
                titleSection
                detailsCard

                Spacer()

                backButton
            }
            .padding(.horizontal, AppDimens.spacingXXL)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                checkScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }

    private var checkmarkIcon: some View {
        ZStack {
            Circle()
                .fill(AppColors.success.opacity(0.15))
                .frame(width: 100, height: 100)
            Image(systemName: AppIcons.checkmarkSeal)
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(AppColors.success)
        }
        .scaleEffect(checkScale)
    }

    private var titleSection: some View {
        Text(AppStrings.presenceConfirmed)
            .font(.system(size: AppDimens.fontTitle1, weight: .bold))
            .foregroundColor(AppColors.success)
            .opacity(contentOpacity)
    }

    private var detailsCard: some View {
        VStack(spacing: AppDimens.spacingLG) {
            detailRow(label: AppStrings.discipline, value: className)
            Divider()
            detailRow(label: AppStrings.schedule, value: time)
            Divider()
            detailRow(label: AppStrings.time, value: elapsedFormatted, valueColor: AppColors.success)
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .opacity(contentOpacity)
    }

    private func detailRow(label: String, value: String, valueColor: Color = AppColors.textPrimary) -> some View {
        HStack {
            Text(label)
                .font(.system(size: AppDimens.fontSmall, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }

    private var backButton: some View {
        Button {
            onDismiss()
        } label: {
            Text(AppStrings.backToHome)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: AppDimens.buttonHeight)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .opacity(contentOpacity)
        .padding(.bottom, AppDimens.spacing4XL)
    }
}

#Preview {
    AttendanceConfirmedView(
        className: "Cálculo Diferencial",
        time: "14:00",
        elapsedTime: 1.7
    ) {}
}
