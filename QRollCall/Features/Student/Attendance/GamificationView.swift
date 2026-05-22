//
//  GamificationView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct GamificationView: View {
    let words: [String]
    let correctWords: Set<String>
    let onSuccess: () -> Void
    let onFailure: () -> Void

    @State private var selectedWords: Set<String> = []
    @State private var timeRemaining = 30
    @State private var timer: Timer?

    private let columns = [
        GridItem(.flexible(), spacing: AppDimens.spacingMD),
        GridItem(.flexible(), spacing: AppDimens.spacingMD)
    ]

    var body: some View {
        VStack(spacing: AppDimens.spacingXXL) {
            headerSection
            timerSection
            wordsGrid
            Spacer()
            confirmButton
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .padding(.vertical, AppDimens.spacingXL)
        .background(AppColors.background)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppDimens.spacingMD) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryOpacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: AppIcons.gameController)
                    .font(.system(size: AppDimens.iconXXL, weight: .medium))
                    .foregroundColor(AppColors.primary)
            }

            Text(AppStrings.gamificationTitle)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(AppStrings.gamificationSubtitle)
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Timer

    private var timerSection: some View {
        HStack(spacing: AppDimens.spacingSM) {
            Image(systemName: AppIcons.timer)
                .font(.system(size: AppDimens.iconSM))
            Text("\(timeRemaining)s")
                .font(.system(size: AppDimens.fontCallout, weight: .bold))
        }
        .foregroundColor(timeRemaining <= 10 ? AppColors.error : AppColors.primary)
        .padding(.horizontal, AppDimens.spacingLG)
        .padding(.vertical, AppDimens.spacingSM)
        .background((timeRemaining <= 10 ? AppColors.error : AppColors.primary).opacity(0.1))
        .clipShape(Capsule())
    }

    // MARK: - Words Grid

    private var wordsGrid: some View {
        LazyVGrid(columns: columns, spacing: AppDimens.spacingMD) {
            ForEach(words, id: \.self) { word in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        if selectedWords.contains(word) {
                            selectedWords.remove(word)
                        } else {
                            selectedWords.insert(word)
                        }
                    }
                } label: {
                    Text(word)
                        .font(.system(size: AppDimens.fontSmall, weight: selectedWords.contains(word) ? .bold : .medium))
                        .foregroundColor(selectedWords.contains(word) ? .white : AppColors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppDimens.spacingLG)
                        .background(selectedWords.contains(word) ? AppColors.primary : AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                                .stroke(selectedWords.contains(word) ? AppColors.primary : AppColors.primaryOpacity(0.15), lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Button {
            stopTimer()
            if selectedWords == correctWords {
                onSuccess()
            } else {
                onFailure()
            }
        } label: {
            Text(AppStrings.confirm)
                .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppDimens.buttonHeight)
                .background(selectedWords.isEmpty ? AppColors.primaryOpacity(0.4) : AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .disabled(selectedWords.isEmpty)
        .padding(.bottom, AppDimens.spacingLG)
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                onFailure()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    GamificationView(
        words: ["HTML", "CSS", "FUTEBOL", "React", "RECEITA", "JavaScript", "CINEMA", "PRAIA"],
        correctWords: ["HTML", "CSS", "React", "JavaScript"],
        onSuccess: {},
        onFailure: {}
    )
}
