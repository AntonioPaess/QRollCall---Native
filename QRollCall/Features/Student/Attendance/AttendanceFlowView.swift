//
//  AttendanceFlowView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct AttendanceFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AttendanceFlowViewModel

    init(attendance: ChamadaAtivaDTO) {
        _viewModel = StateObject(wrappedValue: AttendanceFlowViewModel(chamada: attendance))
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .loadingChamada:
                    loadingView

                case .outOfRange:
                    OutOfRangeView {
                        viewModel.retryRange()
                    }

                case .gamification:
                    GamificationView(
                        words: viewModel.allWords,
                        correctWords: viewModel.correctWords,
                        onSuccess: { viewModel.gamificationSucceeded() },
                        onFailure: { viewModel.gamificationFailed() }
                    )

                case .gamificationFail:
                    GamificationFailView {
                        viewModel.retryGamification()
                    }

                case .codeEntry:
                    codeEntryView

                case .faceID, .submitting:
                    submittingView

                case .confirmed:
                    AttendanceConfirmedView(
                        className: viewModel.chamada.materiaNome,
                        time: viewModel.chamada.startTime,
                        elapsedTime: viewModel.elapsedTime,
                        didConfirm: viewModel.didConfirm,
                        failureReasons: viewModel.failureReasons
                    ) {
                        dismiss()
                    }

                case .error(let message):
                    errorView(message)
                }
            }
            .task {
                if viewModel.phase == .loadingChamada {
                    await viewModel.bootstrap()
                }
            }
            .onChange(of: viewModel.phase) { _, new in
                if new == .faceID {
                    Task { await viewModel.runFaceIDAndSubmit() }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !isTerminalPhase {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: AppIcons.arrowBack)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(viewModel.chamada.materiaNome)
                        .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                }
            }
        }
    }

    private var isTerminalPhase: Bool {
        switch viewModel.phase {
        case .confirmed, .submitting, .faceID: return true
        default: return false
        }
    }

    private var loadingView: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: AppDimens.spacingLG) {
                ProgressView().tint(AppColors.primary)
                Text("Validando localização…")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private var submittingView: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: AppDimens.spacingLG) {
                ProgressView().tint(AppColors.primary)
                Text("Confirmando presença…")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private var codeEntryView: some View {
        VStack(spacing: AppDimens.spacingXL) {
            Spacer()

            VStack(spacing: AppDimens.spacingMD) {
                Image(systemName: AppIcons.lockIcon)
                    .font(.system(size: AppDimens.icon3XL))
                    .foregroundColor(AppColors.primary)

                Text("Insira o código da chamada")
                    .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Peça ao professor o código exibido no quadro.")
                    .font(.system(size: AppDimens.fontBody))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Código", text: $viewModel.codeInput)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .padding(AppDimens.spacingLG)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))

            Spacer()

            Button {
                viewModel.confirmCodeAndProceedToFace()
            } label: {
                Text(AppStrings.confirm)
                    .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: AppDimens.buttonHeight)
                    .background(viewModel.codeInput.isEmpty ? AppColors.primaryOpacity(0.4) : AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.codeInput.isEmpty)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .background(AppColors.background)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: AppDimens.spacingXL) {
            Image(systemName: AppIcons.xCircleFill)
                .font(.system(size: 56))
                .foregroundColor(AppColors.error)
            Text(message)
                .font(.system(size: AppDimens.fontBody, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppDimens.spacingXXL)
            Button("Voltar") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

#Preview {
    AttendanceFlowView(attendance: ChamadaAtivaDTO(
        idChamada: 1,
        idQrcode: UUID().uuidString,
        materiaNome: "Programação Web",
        sala: "Lab 101",
        classType: "PRIMEIRA",
        startTime: "10:00",
        timeRemainingSec: 600,
        jaRegistrouPresenca: false,
        keywords: ["HTML", "CSS", "JavaScript", "React"],
        beaconUuid: UUID().uuidString,
        beaconMajor: 1,
        beaconMinor: 1
    ))
}
