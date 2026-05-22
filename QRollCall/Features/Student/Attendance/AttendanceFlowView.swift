//
//  AttendanceFlowView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

enum AttendanceStep {
    case mockChoice
    case checkingRange
    case outOfRange
    case gamification
    case gamificationFail
    case faceID
    case confirmed
}

struct AttendanceFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep: AttendanceStep = .mockChoice
    @State private var startTime = Date()
    @State private var mockWillFail = false

    private let attendance = AttendanceMockData.activeAttendance

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .mockChoice:
                    mockChoiceView

                case .checkingRange:
                    ZStack {
                        AppColors.background.ignoresSafeArea()
                        ProgressView().tint(AppColors.primary)
                    }
                    .onAppear { checkRange() }

                case .outOfRange:
                    OutOfRangeView {
                        currentStep = .checkingRange
                        AttendanceMockData.isInBluetoothRange = true
                    }

                case .gamification:
                    GamificationView(
                        words: attendance.allWords,
                        correctWords: Set(attendance.correctWords),
                        onSuccess: {
                            startTime = Date()
                            currentStep = .faceID
                        },
                        onFailure: {
                            currentStep = .gamificationFail
                        }
                    )

                case .gamificationFail:
                    GamificationFailView {
                        currentStep = .gamification
                    }

                case .faceID:
                    FaceIDCheckView(
                        onSuccess: {
                            currentStep = .confirmed
                        }
                    )

                case .confirmed:
                    AttendanceConfirmedView(
                        className: attendance.className,
                        time: attendance.startTime,
                        elapsedTime: Date().timeIntervalSince(startTime)
                    ) {
                        dismiss()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if currentStep != .confirmed && currentStep != .faceID {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: AppIcons.arrowBack)
                                .foregroundColor(currentStep == .outOfRange || currentStep == .gamificationFail || currentStep == .checkingRange ? .white : AppColors.textPrimary)
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    if currentStep == .gamification || currentStep == .mockChoice {
                        Text(attendance.className)
                            .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    }
                }
            }
        }
    }

    // MARK: - Mock Choice

    private var mockChoiceView: some View {
        VStack(spacing: AppDimens.spacingXXL) {
            Spacer()

            VStack(spacing: AppDimens.spacingMD) {
                Image(systemName: AppIcons.gameController)
                    .font(.system(size: AppDimens.icon3XL))
                    .foregroundColor(AppColors.primary)

                Text("Modo de teste")
                    .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("Escolha o cenário para testar o fluxo de presença")
                    .font(.system(size: AppDimens.fontBody, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: AppDimens.spacingMD) {
                Button {
                    AttendanceMockData.isInBluetoothRange = false
                    currentStep = .checkingRange
                } label: {
                    HStack(spacing: AppDimens.spacingMD) {
                        Image(systemName: AppIcons.bluetoothOff)
                            .font(.system(size: AppDimens.iconLG))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fora do alcance")
                                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                            Text("Simula estar longe da sala")
                                .font(.system(size: AppDimens.fontCaption))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }
                    .foregroundColor(AppColors.error)
                    .padding(AppDimens.spacingLG)
                    .background(AppColors.error.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                            .stroke(AppColors.error.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    mockWillFail = true
                    AttendanceMockData.isInBluetoothRange = true
                    currentStep = .checkingRange
                } label: {
                    HStack(spacing: AppDimens.spacingMD) {
                        Image(systemName: AppIcons.xCircleFill)
                            .font(.system(size: AppDimens.iconLG))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Falhar na gamificação")
                                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                            Text("Resposta errada no desafio")
                                .font(.system(size: AppDimens.fontCaption))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }
                    .foregroundColor(AppColors.warning)
                    .padding(AppDimens.spacingLG)
                    .background(AppColors.warning.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                            .stroke(AppColors.warning.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    mockWillFail = false
                    AttendanceMockData.isInBluetoothRange = true
                    currentStep = .checkingRange
                } label: {
                    HStack(spacing: AppDimens.spacingMD) {
                        Image(systemName: AppIcons.checkCircleFill)
                            .font(.system(size: AppDimens.iconLG))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fluxo completo (sucesso)")
                                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                            Text("Gamificação + FaceID + Confirmação")
                                .font(.system(size: AppDimens.fontCaption))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                    }
                    .foregroundColor(AppColors.success)
                    .padding(AppDimens.spacingLG)
                    .background(AppColors.success.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                            .stroke(AppColors.success.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .background(AppColors.background)
    }

    // MARK: - Range Check

    private func checkRange() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                if !AttendanceMockData.isInBluetoothRange {
                    currentStep = .outOfRange
                } else if mockWillFail {
                    currentStep = .gamificationFail
                } else {
                    currentStep = .gamification
                }
            }
        }
    }
}

#Preview {
    AttendanceFlowView()
}
