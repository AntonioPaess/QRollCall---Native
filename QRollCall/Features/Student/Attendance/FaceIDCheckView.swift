//
//  FaceIDCheckView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ValidationStep: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    var activeColor: Color
    var state: StepState = .pending

    enum StepState {
        case pending, active, completed
    }
}

struct FaceIDCheckView: View {
    let onSuccess: () -> Void

    @State private var steps: [ValidationStep] = [
        ValidationStep(icon: AppIcons.checkCircleFill, label: "QR Code lido", activeColor: AppColors.success),
        ValidationStep(icon: "arrow.triangle.2.circlepath", label: "Validando rosto", activeColor: AppColors.purple),
        ValidationStep(icon: "location", label: "Verificando localização", activeColor: AppColors.textTertiary),
        ValidationStep(icon: AppIcons.clock, label: "Confirmando horário", activeColor: AppColors.textTertiary)
    ]

    @State private var statusText = "Validando sua presença..."

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: AppDimens.spacingXXXL) {
                Spacer()

                VStack(alignment: .leading, spacing: AppDimens.spacingXXL) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { _, step in
                        HStack(spacing: AppDimens.spacingLG) {
                            ZStack {
                                Circle()
                                    .fill(circleColor(for: step))
                                    .frame(width: 48, height: 48)
                                Image(systemName: step.icon)
                                    .font(.system(size: AppDimens.iconLG, weight: .medium))
                                    .foregroundColor(iconColor(for: step))
                            }

                            Text(step.label)
                                .font(.system(size: AppDimens.fontCallout, weight: .medium))
                                .foregroundColor(textColor(for: step))
                        }
                        .animation(.easeInOut(duration: 0.4), value: step.state)
                    }
                }

                Text(statusText)
                    .font(.system(size: AppDimens.fontBody, weight: .regular))
                    .foregroundColor(AppColors.textTertiary)
                    .padding(.top, AppDimens.spacingLG)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, AppDimens.spacing4XL)
        }
        .onAppear { runValidation() }
    }

    // MARK: - Colors

    private func circleColor(for step: ValidationStep) -> Color {
        switch step.state {
        case .completed, .active: return step.activeColor
        case .pending: return AppColors.textTertiary.opacity(0.2)
        }
    }

    private func iconColor(for step: ValidationStep) -> Color {
        switch step.state {
        case .completed, .active: return .white
        case .pending: return AppColors.textTertiary
        }
    }

    private func textColor(for step: ValidationStep) -> Color {
        switch step.state {
        case .completed, .active: return AppColors.textPrimary
        case .pending: return AppColors.textTertiary
        }
    }

    // MARK: - Animation

    private func runValidation() {
        steps[0].state = .completed
        steps[1].state = .active

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                steps[1].state = .completed
                steps[2].state = .active
                steps[2].activeColor = AppColors.primary
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation {
                steps[2].state = .completed
                steps[3].state = .active
                steps[3].activeColor = AppColors.primary
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                steps[3].state = .completed
                statusText = "Presença validada!"
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.8) {
            onSuccess()
        }
    }
}

#Preview {
    FaceIDCheckView(onSuccess: {})
}
