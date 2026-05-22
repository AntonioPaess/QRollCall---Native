//
//  LiveAttendanceView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct LiveAttendanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var confirmedIDs: Set<UUID> = []
    @State private var timeRemaining: Int
    @State private var showSummary = false
    @State private var timer: Timer?

    let className: String
    let classType: ClassType
    let totalStudents: Int
    let durationMinutes: Int

    private let allStudents = ProfessorHomeMockData.studentsForClass

    init(className: String, classType: ClassType, totalStudents: Int, durationMinutes: Int) {
        self.className = className
        self.classType = classType
        self.totalStudents = totalStudents
        self.durationMinutes = durationMinutes
        self._timeRemaining = State(initialValue: durationMinutes * 60)
    }

    private var confirmedStudents: [StudentAttendanceRecord] {
        allStudents.filter { confirmedIDs.contains($0.id) }
    }

    private var absentStudents: [StudentAttendanceRecord] {
        allStudents.filter { !confirmedIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusHeader
                studentsList
                closeButton
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.liveAttendanceTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: AppIcons.arrowBack)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .onAppear { startSimulation() }
            .onDisappear { stopTimer() }
            .fullScreenCover(isPresented: $showSummary) {
                AttendanceSummaryView(
                    className: className,
                    classType: classType,
                    presentStudents: confirmedStudents,
                    absentStudents: absentStudents,
                    totalStudents: totalStudents
                )
            }
        }
    }

    // MARK: - Status Header

    private var statusHeader: some View {
        VStack(spacing: AppDimens.spacingLG) {
            Text(className)
                .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            Text(classType.rawValue)
                .font(.system(size: AppDimens.fontCaption, weight: .medium))
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, AppDimens.spacingMD)
                .padding(.vertical, AppDimens.spacingXS)
                .background(AppColors.primaryOpacity(0.1))
                .clipShape(Capsule())

            ZStack {
                Circle()
                    .stroke(AppColors.primaryOpacity(0.15), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(confirmedIDs.count) / CGFloat(max(allStudents.count, 1)))
                    .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: confirmedIDs.count)

                VStack(spacing: 2) {
                    Text("\(confirmedIDs.count)")
                        .font(.system(size: AppDimens.fontHero, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("/\(allStudents.count)")
                        .font(.system(size: AppDimens.fontSmall, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            HStack(spacing: AppDimens.spacingXS) {
                Image(systemName: AppIcons.timer)
                    .font(.system(size: AppDimens.iconSM))
                    .foregroundColor(timeRemaining < 60 ? AppColors.error : AppColors.textSecondary)
                Text(formatTime(timeRemaining))
                    .font(.system(size: AppDimens.fontCallout, weight: .medium))
                    .foregroundColor(timeRemaining < 60 ? AppColors.error : AppColors.textSecondary)
            }
        }
        .padding(AppDimens.spacingXXL)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
    }

    // MARK: - Students List (ALL students shown)

    private var studentsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppDimens.spacingSM) {
                ForEach(allStudents) { student in
                    let isConfirmed = confirmedIDs.contains(student.id)

                    HStack(spacing: AppDimens.spacingMD) {
                        ZStack {
                            Circle()
                                .fill((isConfirmed ? AppColors.success : AppColors.textTertiary).opacity(0.12))
                                .frame(width: 36, height: 36)
                            Text(student.initials)
                                .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                                .foregroundColor(isConfirmed ? AppColors.success : AppColors.textTertiary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(student.name)
                                .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                                .foregroundColor(isConfirmed ? AppColors.textPrimary : AppColors.textTertiary)
                            if isConfirmed, let time = student.confirmedAt {
                                Text(time)
                                    .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }

                        Spacer()

                        Image(systemName: isConfirmed ? AppIcons.checkCircleFill : AppIcons.checkCircle)
                            .font(.system(size: AppDimens.iconMD))
                            .foregroundColor(isConfirmed ? AppColors.success : AppColors.textTertiary.opacity(0.4))
                    }
                    .padding(AppDimens.spacingMD)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
                    .animation(.easeInOut(duration: 0.3), value: isConfirmed)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.vertical, AppDimens.spacingLG)
        }
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button {
            stopTimer()
            showSummary = true
        } label: {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.stop)
                    .font(.system(size: AppDimens.iconMD))
                Text(AppStrings.closeAttendance)
                    .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(AppColors.error)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .padding(AppDimens.spacingXXL)
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func startSimulation() {
        let presentStudents = allStudents.filter { $0.isPresent }
        var index = 0

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }

            if index < presentStudents.count && Int.random(in: 0...2) == 0 {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    confirmedIDs.insert(presentStudents[index].id)
                }
                index += 1
            }

            if timeRemaining == 0 {
                stopTimer()
                showSummary = true
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    LiveAttendanceView(
        className: "Programação Web",
        classType: .first,
        totalStudents: 35,
        durationMinutes: 1
    )
}
