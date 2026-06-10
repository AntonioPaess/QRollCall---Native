//
//  CreateAttendanceView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct CreateAttendanceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateAttendanceViewModel()
    @State private var liveChamada: ChamadaCreatedDTO?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppDimens.spacingXL) {
                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(.system(size: AppDimens.fontCaption))
                            .foregroundColor(AppColors.error)
                    }
                    classPickerSection
                    classTypeSection
                    gamificationSection
                    durationSection
                    startButton
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.vertical, AppDimens.spacingXL)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.createAttendanceTitle)
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadTurmas() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: AppIcons.xCircle)
                            .font(.system(size: AppDimens.iconXL))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .fullScreenCover(item: $liveChamada) { chamada in
                LiveAttendanceView(
                    chamada: chamada,
                    turmaNome: viewModel.selectedTurma?.nome ?? "",
                    classType: viewModel.classType,
                    totalStudents: viewModel.selectedTurma?.totalStudents ?? 0,
                    durationMinutes: viewModel.durationMinutes
                )
            }
        }
    }

    private var classPickerSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.selectClass)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            if viewModel.turmas.isEmpty && !viewModel.isLoading {
                Text("Sem turmas cadastradas.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            }

            ForEach(viewModel.turmas) { cls in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectTurma(cls)
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                            Text(cls.nome)
                                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("\(cls.horarioSemanal) • \(cls.sala)")
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        if viewModel.selectedTurma?.id == cls.id {
                            Image(systemName: AppIcons.checkCircleFill)
                                .font(.system(size: AppDimens.iconLG))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(AppDimens.spacingLG)
                    .background(viewModel.selectedTurma?.id == cls.id ? AppColors.primaryOpacity(0.08) : AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                            .stroke(viewModel.selectedTurma?.id == cls.id ? AppColors.primary : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var classTypeSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.classType)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 0) {
                classTypeButton(.first, label: AppStrings.firstClass)
                classTypeButton(.second, label: AppStrings.secondClass)
                classTypeButton(.conjugated, label: AppStrings.conjugatedClasses)
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))

            Text(viewModel.classType == .conjugated ? AppStrings.twoAbsences : AppStrings.oneAbsence)
                .font(.system(size: AppDimens.fontCaption, weight: .medium))
                .foregroundColor(viewModel.classType == .conjugated ? AppColors.warning : AppColors.textSecondary)
                .padding(.horizontal, AppDimens.spacingXS)
        }
    }

    private func classTypeButton(_ type: ClassType, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.classType = type
            }
        } label: {
            Text(label)
                .font(.system(size: AppDimens.fontCaption, weight: viewModel.classType == type ? .semibold : .regular))
                .foregroundColor(viewModel.classType == type ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppDimens.spacingMD)
                .background(viewModel.classType == type ? AppColors.primary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
    }

    private var gamificationSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.gamificationWords)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TextField(AppStrings.gamificationPlaceholder, text: $viewModel.keywordsRaw, axis: .vertical)
                .font(.system(size: AppDimens.fontBody))
                .lineLimit(2...4)
                .padding(AppDimens.spacingLG)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
    }

    private let durationOptions = [3, 5, 10]

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.duration)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 0) {
                ForEach(durationOptions, id: \.self) { minutes in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.durationMinutes = minutes
                        }
                    } label: {
                        Text("\(minutes) min")
                            .font(.system(size: AppDimens.fontSmall, weight: viewModel.durationMinutes == minutes ? .semibold : .regular))
                            .foregroundColor(viewModel.durationMinutes == minutes ? .white : AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppDimens.spacingMD)
                            .background(viewModel.durationMinutes == minutes ? AppColors.primary : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
    }

    private var startButton: some View {
        Button {
            Task {
                if let chamada = await viewModel.startAttendance() {
                    liveChamada = chamada
                }
            }
        } label: {
            HStack(spacing: AppDimens.spacingSM) {
                if viewModel.isStarting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: AppIcons.play)
                        .font(.system(size: AppDimens.iconMD))
                    Text(AppStrings.startButton2)
                        .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(viewModel.selectedTurma != nil ? AppColors.primary : AppColors.primaryOpacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.selectedTurma == nil || viewModel.isStarting)
        .padding(.top, AppDimens.spacingSM)
    }
}

extension ChamadaCreatedDTO: Identifiable {
    var id: Int64 { idChamada }
}

#Preview {
    CreateAttendanceView()
}
