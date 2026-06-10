//
//  LiveAttendanceView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct LiveAttendanceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: LiveAttendanceViewModel

    let chamada: ChamadaCreatedDTO
    let turmaNome: String
    let classType: ClassType
    let totalStudents: Int
    let durationMinutes: Int

    @State private var showSummary = false

    init(chamada: ChamadaCreatedDTO,
         turmaNome: String,
         classType: ClassType,
         totalStudents: Int,
         durationMinutes: Int) {
        self.chamada = chamada
        self.turmaNome = turmaNome
        self.classType = classType
        self.totalStudents = totalStudents
        self.durationMinutes = durationMinutes
        _viewModel = StateObject(wrappedValue: LiveAttendanceViewModel(
            idChamada: chamada.idChamada,
            totalStudents: totalStudents,
            durationMinutes: durationMinutes
        ))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statusHeader
                if let msg = viewModel.errorMessage {
                    Text(msg)
                        .font(.system(size: AppDimens.fontCaption))
                        .foregroundColor(AppColors.error)
                        .padding(.horizontal, AppDimens.spacingXXL)
                }
                confirmedList
                closeButton
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.liveAttendanceTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.stop()
                        dismiss()
                    } label: {
                        Image(systemName: AppIcons.arrowBack)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .onAppear { viewModel.start() }
            .onDisappear { viewModel.stop() }
            .fullScreenCover(isPresented: $showSummary) {
                AttendanceSummaryView(
                    chamada: chamada,
                    className: turmaNome,
                    classType: classType,
                    presentStudents: viewModel.confirmados,
                    totalStudents: viewModel.totalStudents
                )
            }
        }
    }

    private var statusHeader: some View {
        VStack(spacing: AppDimens.spacingLG) {
            Text(turmaNome)
                .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            Text(classType.rawValue)
                .font(.system(size: AppDimens.fontCaption, weight: .medium))
                .foregroundColor(AppColors.primary)
                .padding(.horizontal, AppDimens.spacingMD)
                .padding(.vertical, AppDimens.spacingXS)
                .background(AppColors.primaryOpacity(0.1))
                .clipShape(Capsule())

            HStack(spacing: AppDimens.spacingMD) {
                Text("Código:")
                    .font(.system(size: AppDimens.fontSmall, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                Text(chamada.codigo)
                    .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }

            ZStack {
                Circle()
                    .stroke(AppColors.primaryOpacity(0.15), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.confirmedCount) / CGFloat(max(viewModel.totalStudents, 1)))
                    .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.confirmedCount)

                VStack(spacing: 2) {
                    Text("\(viewModel.confirmedCount)")
                        .font(.system(size: AppDimens.fontHero, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("/\(viewModel.totalStudents)")
                        .font(.system(size: AppDimens.fontSmall, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            HStack(spacing: AppDimens.spacingXS) {
                Image(systemName: AppIcons.timer)
                    .font(.system(size: AppDimens.iconSM))
                    .foregroundColor(viewModel.timeRemaining < 60 ? AppColors.error : AppColors.textSecondary)
                Text(formatTime(viewModel.timeRemaining))
                    .font(.system(size: AppDimens.fontCallout, weight: .medium))
                    .foregroundColor(viewModel.timeRemaining < 60 ? AppColors.error : AppColors.textSecondary)
            }
        }
        .padding(AppDimens.spacingXXL)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
    }

    private var confirmedList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppDimens.spacingSM) {
                if viewModel.confirmados.isEmpty {
                    Text("Aguardando alunos confirmarem…")
                        .font(.system(size: AppDimens.fontCaption))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, AppDimens.spacingXL)
                }
                ForEach(viewModel.confirmados) { student in
                    HStack(spacing: AppDimens.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(AppColors.success.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Text(initials(student.name))
                                .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                                .foregroundColor(AppColors.success)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(student.name)
                                .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            Text(student.matricula)
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Spacer()

                        if let time = student.confirmedAt {
                            Text(time)
                                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }

                        Image(systemName: AppIcons.checkCircleFill)
                            .font(.system(size: AppDimens.iconMD))
                            .foregroundColor(AppColors.success)
                    }
                    .padding(AppDimens.spacingMD)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.vertical, AppDimens.spacingLG)
        }
    }

    private var closeButton: some View {
        Button {
            viewModel.stop()
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

    private func formatTime(_ seconds: Int) -> String {
        let m = max(seconds, 0) / 60
        let s = max(seconds, 0) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func initials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(f)\(l)".uppercased()
    }
}
