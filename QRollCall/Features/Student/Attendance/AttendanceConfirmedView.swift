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
    let didConfirm: Bool
    let failureReasons: [String]
    let onDismiss: () -> Void

    @State private var checkScale: CGFloat = 0
    @State private var contentOpacity: Double = 0

    private var elapsedFormatted: String {
        String(format: "%.1fs", elapsedTime)
    }

    private var accentColor: Color {
        didConfirm ? AppColors.success : AppColors.error
    }

    private var titleText: String {
        didConfirm ? AppStrings.presenceConfirmed : "Presença não validada"
    }

    private var iconName: String {
        didConfirm ? AppIcons.checkmarkSeal : AppIcons.xCircleFill
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppDimens.spacingXXXL) {
                Spacer()

                iconView
                titleSection
                detailsCard

                if !didConfirm && !failureReasons.isEmpty {
                    reasonsCard
                }

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

    private var iconView: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: 100, height: 100)
            Image(systemName: iconName)
                .font(.system(size: 56, weight: .medium))
                .foregroundColor(accentColor)
        }
        .scaleEffect(checkScale)
    }

    private var titleSection: some View {
        Text(titleText)
            .font(.system(size: AppDimens.fontTitle1, weight: .bold))
            .foregroundColor(accentColor)
            .opacity(contentOpacity)
            .multilineTextAlignment(.center)
    }

    private var detailsCard: some View {
        VStack(spacing: AppDimens.spacingLG) {
            detailRow(label: AppStrings.discipline, value: className)
            Divider()
            detailRow(label: AppStrings.schedule, value: time)
            Divider()
            detailRow(label: AppStrings.time, value: elapsedFormatted, valueColor: accentColor)
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        .opacity(contentOpacity)
    }

    private var reasonsCard: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text("Motivos")
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            ForEach(failureReasons, id: \.self) { reason in
                HStack(spacing: AppDimens.spacingSM) {
                    Image(systemName: AppIcons.xCircleFill)
                        .font(.system(size: AppDimens.iconSM))
                        .foregroundColor(AppColors.error)
                    Text(reason)
                        .font(.system(size: AppDimens.fontSmall))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingXL)
        .background(AppColors.error.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
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

#Preview("Sucesso") {
    AttendanceConfirmedView(
        className: "Cálculo Diferencial",
        time: "14:00",
        elapsedTime: 1.7,
        didConfirm: true,
        failureReasons: []
    ) {}
}

#Preview("Falha") {
    AttendanceConfirmedView(
        className: "Cálculo Diferencial",
        time: "14:00",
        elapsedTime: 2.3,
        didConfirm: false,
        failureReasons: ["Código incorreto", "Localização fora do raio"]
    ) {}
}
