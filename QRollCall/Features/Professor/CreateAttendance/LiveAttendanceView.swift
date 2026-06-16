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
    @State private var hasStarted = false
    @State private var ackPhoneStaysUnlocked = false
    @State private var ackBluetoothReady = false
    @State private var ackStayInApp = false

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
            chamada: chamada,
            totalStudents: totalStudents,
            durationMinutes: durationMinutes
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if hasStarted {
                    liveContent
                } else {
                    preflightChecklist
                }
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
            .alert(AppStrings.liveInterruptionAlertTitle,
                   isPresented: $viewModel.didInterruptBroadcast,
                   actions: {
                       Button(AppStrings.liveInterruptionAlertConfirm, role: .cancel) {
                           viewModel.acknowledgeInterruption()
                       }
                   },
                   message: {
                       Text(AppStrings.liveInterruptionAlertMessage)
                   })
        }
    }

    // MARK: - Pre-flight checklist

    private var preflightChecklist: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                VStack(alignment: .leading, spacing: AppDimens.spacingSM) {
                    Text(AppStrings.livePreflightTitle)
                        .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(AppStrings.livePreflightSubtitle)
                        .font(.system(size: AppDimens.fontBody))
                        .foregroundColor(AppColors.textSecondary)
                }

                VStack(spacing: AppDimens.spacingMD) {
                    checklistRow(text: AppStrings.livePreflightCheckBluetooth,
                                 isChecked: $ackBluetoothReady)
                    checklistRow(text: AppStrings.livePreflightCheckUnlocked,
                                 isChecked: $ackPhoneStaysUnlocked)
                    checklistRow(text: AppStrings.livePreflightCheckStayInApp,
                                 isChecked: $ackStayInApp)
                }

                criticalNotice

                Button {
                    hasStarted = true
                    viewModel.start()
                } label: {
                    Text(AppStrings.livePreflightStartCTA)
                        .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppDimens.buttonHeight)
                        .background(allChecked ? AppColors.primary : AppColors.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
                }
                .buttonStyle(.plain)
                .disabled(!allChecked)
            }
            .padding(AppDimens.spacingXXL)
        }
    }

    private func checklistRow(text: String, isChecked: Binding<Bool>) -> some View {
        Button {
            isChecked.wrappedValue.toggle()
        } label: {
            HStack(spacing: AppDimens.spacingMD) {
                Image(systemName: isChecked.wrappedValue ? AppIcons.checkboxFilled : AppIcons.checkboxEmpty)
                    .font(.system(size: AppDimens.iconLG))
                    .foregroundColor(isChecked.wrappedValue ? AppColors.success : AppColors.textTertiary)
                Text(text)
                    .font(.system(size: AppDimens.fontBody))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(AppDimens.spacingMD)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
        }
        .buttonStyle(.plain)
    }

    private var criticalNotice: some View {
        HStack(alignment: .top, spacing: AppDimens.spacingSM) {
            Image(systemName: AppIcons.exclamation)
                .foregroundColor(AppColors.danger)
            Text(AppStrings.livePreflightCriticalNotice)
                .font(.system(size: AppDimens.fontCaption))
                .foregroundColor(AppColors.danger)
        }
        .padding(AppDimens.spacingMD)
        .background(AppColors.danger.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusSM))
    }

    private var allChecked: Bool {
        ackBluetoothReady && ackPhoneStaysUnlocked && ackStayInApp
    }

    // MARK: - Live content

    private var liveContent: some View {
        VStack(spacing: 0) {
            broadcastBanner
            statusHeader
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.danger)
                    .padding(.horizontal, AppDimens.spacingXXL)
            }
            confirmedList
            closeButton
        }
    }

    private var broadcastBanner: some View {
        HStack(spacing: AppDimens.spacingSM) {
            Image(systemName: AppIcons.bluetoothOn)
                .font(.system(size: AppDimens.iconMD))
            VStack(alignment: .leading, spacing: 2) {
                Text(AppStrings.liveBroadcastBannerTitle)
                    .font(.system(size: AppDimens.fontSmall, weight: .semibold))
                Text(AppStrings.liveBroadcastBannerSubtitle)
                    .font(.system(size: AppDimens.fontCaption))
                    .opacity(0.85)
            }
            Spacer()
            broadcastStatusBadge
        }
        .foregroundColor(.white)
        .padding(AppDimens.spacingMD)
        .frame(maxWidth: .infinity)
        .background(broadcastBannerColor)
    }

    private var broadcastStatusBadge: some View {
        Group {
            switch viewModel.broadcaster.state {
            case .advertising:
                Text(AppStrings.liveBroadcastBadgeActive)
                    .font(.system(size: AppDimens.fontCaption, weight: .bold))
            case .waitingForBluetooth, .idle:
                Text(AppStrings.liveBroadcastBadgeWaiting)
                    .font(.system(size: AppDimens.fontCaption, weight: .bold))
            case .failed(let msg):
                Text(msg.uppercased())
                    .font(.system(size: AppDimens.fontCaption, weight: .bold))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, AppDimens.spacingSM)
        .padding(.vertical, 2)
        .background(.white.opacity(0.2))
        .clipShape(Capsule())
    }

    /// Cor do banner segue a semântica do design system:
    /// - `success` quando transmitindo (estado-objetivo atingido).
    /// - `warning` enquanto aguardando o BT estar pronto (atenção, não erro).
    /// - `danger` em falha (BT desligado / permissão negada).
    private var broadcastBannerColor: Color {
        switch viewModel.broadcaster.state {
        case .advertising:                  return AppColors.success
        case .waitingForBluetooth, .idle:   return AppColors.warning
        case .failed:                       return AppColors.danger
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
                    .foregroundColor(viewModel.timeRemaining < 60 ? AppColors.danger : AppColors.textSecondary)
                Text(formatTime(viewModel.timeRemaining))
                    .font(.system(size: AppDimens.fontCallout, weight: .medium))
                    .foregroundColor(viewModel.timeRemaining < 60 ? AppColors.danger : AppColors.textSecondary)
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
            .background(AppColors.danger)
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
