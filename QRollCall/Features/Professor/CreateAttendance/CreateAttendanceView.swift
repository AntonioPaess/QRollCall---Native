//
//  CreateAttendanceView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct CreateAttendanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedClass: ProfessorClass?
    @State private var selectedClassType: ClassType = .first
    @State private var keywords = ""
    @State private var durationMinutes: Int = 5
    @State private var showLiveAttendance = false
    @State private var isScheduled = false
    @State private var scheduledDate = Date().addingTimeInterval(3600)

    private let classes = ProfessorHomeMockData.classes

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppDimens.spacingXL) {
                    classPickerSection
                    classTypeSection
                    gamificationSection
                    durationSection
                    scheduleSection
                    startButton
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.vertical, AppDimens.spacingXL)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.createAttendanceTitle)
            .navigationBarTitleDisplayMode(.large)
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
            .fullScreenCover(isPresented: $showLiveAttendance) {
                LiveAttendanceView(
                    className: selectedClass?.name ?? "",
                    classType: selectedClassType,
                    totalStudents: selectedClass?.totalStudents ?? 0,
                    durationMinutes: durationMinutes
                )
            }
        }
    }

    // MARK: - Class Picker

    private var classPickerSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.selectClass)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            ForEach(classes) { cls in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedClass = cls
                        if let words = ProfessorHomeMockData.gamificationWordSets[cls.name] {
                            keywords = words.prefix(4).joined(separator: ", ")
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                            Text(cls.name)
                                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text("\(cls.schedule) • \(cls.room)")
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        if selectedClass?.id == cls.id {
                            Image(systemName: AppIcons.checkCircleFill)
                                .font(.system(size: AppDimens.iconLG))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(AppDimens.spacingLG)
                    .background(selectedClass?.id == cls.id ? AppColors.primaryOpacity(0.08) : AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                            .stroke(selectedClass?.id == cls.id ? AppColors.primary : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Class Type

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

            Text(selectedClassType == .conjugated ? AppStrings.twoAbsences : AppStrings.oneAbsence)
                .font(.system(size: AppDimens.fontCaption, weight: .medium))
                .foregroundColor(selectedClassType == .conjugated ? AppColors.warning : AppColors.textSecondary)
                .padding(.horizontal, AppDimens.spacingXS)
        }
    }

    private func classTypeButton(_ type: ClassType, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedClassType = type
            }
        } label: {
            Text(label)
                .font(.system(size: AppDimens.fontCaption, weight: selectedClassType == type ? .semibold : .regular))
                .foregroundColor(selectedClassType == type ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppDimens.spacingMD)
                .background(selectedClassType == type ? AppColors.primary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Gamification

    private var gamificationSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.gamificationWords)
                .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            TextField(AppStrings.gamificationPlaceholder, text: $keywords, axis: .vertical)
                .font(.system(size: AppDimens.fontBody))
                .lineLimit(2...4)
                .padding(AppDimens.spacingLG)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
    }

    // MARK: - Duration

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
                            durationMinutes = minutes
                        }
                    } label: {
                        Text("\(minutes) min")
                            .font(.system(size: AppDimens.fontSmall, weight: durationMinutes == minutes ? .semibold : .regular))
                            .foregroundColor(durationMinutes == minutes ? .white : AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppDimens.spacingMD)
                            .background(durationMinutes == minutes ? AppColors.primary : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
    }

    // MARK: - Schedule

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Toggle(isOn: $isScheduled.animation(.easeInOut(duration: 0.2))) {
                Text("Agendar chamada")
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            .tint(AppColors.primary)

            if isScheduled {
                DatePicker(
                    "Data e hora",
                    selection: $scheduledDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.compact)
                .font(.system(size: AppDimens.fontSmall))
            }
        }
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
    }

    // MARK: - Start Button

    private var startButton: some View {
        Button {
            if isScheduled {
                dismiss()
            } else {
                showLiveAttendance = true
            }
        } label: {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: isScheduled ? AppIcons.clock : AppIcons.play)
                    .font(.system(size: AppDimens.iconMD))
                Text(isScheduled ? "Agendar Chamada" : AppStrings.startButton2)
                    .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(selectedClass != nil ? AppColors.primary : AppColors.primaryOpacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .disabled(selectedClass == nil)
        .padding(.top, AppDimens.spacingSM)
    }
}

#Preview {
    CreateAttendanceView()
}
