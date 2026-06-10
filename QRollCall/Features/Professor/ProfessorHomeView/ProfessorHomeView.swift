//
//  ProfessorHomeView.swift
//  QRollCall
//

import SwiftUI

struct ProfessorHomeView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var viewModel = ProfessorHomeViewModel()
    @State private var showCreateAttendance = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                    PremiumHeader(
                        greeting: AppStrings.greeting,
                        title: "Prof. \(viewModel.perfil?.firstName ?? auth.firstName)"
                    )

                    if let msg = viewModel.errorMessage {
                        Text(msg)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.danger)
                    }

                    startAttendanceCard
                    nextClassCard
                    statsRow
                    recentAttendancesSection
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
            .fullScreenCover(isPresented: $showCreateAttendance) {
                CreateAttendanceView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .dismissAttendanceFlow)) { _ in
                showCreateAttendance = false
                Task { await viewModel.load() }
            }
        }
    }

    private var startAttendanceCard: some View {
        Button {
            showCreateAttendance = true
        } label: {
            HStack(spacing: AppDimens.spacingLG) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.primary.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: AppIcons.play)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.primary)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(AppStrings.startAttendance)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(AppStrings.startAttendanceSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(AppDimens.spacingLG)
            .minimalCard(corner: 16)
        }
        .buttonStyle(.plain)
    }

    private var nextClassCard: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: 6) {
                Image(systemName: AppIcons.clock)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
                Text(AppStrings.currentClass.uppercased())
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .tracking(0.5)
            }

            if let next = viewModel.nextClass {
                Text(next.nome)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(next.startTime) – \(next.endTime) · \(next.sala)")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)

                HStack(spacing: 6) {
                    Image(systemName: AppIcons.people)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
                    Text("\(next.totalStudents) \(AppStrings.students)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .padding(.top, 2)
            } else {
                Text("Sem aulas agendadas")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingLG)
        .minimalCard(corner: 16)
    }

    private var statsRow: some View {
        let s = viewModel.stats
        return HStack(spacing: AppDimens.spacingMD) {
            KPICard(title: AppStrings.averagePresence,
                    value: "\(s?.averagePresence ?? 0)%",
                    icon: AppIcons.chartUp,
                    tint: AppColors.success)
            KPICard(title: AppStrings.classesGiven,
                    value: "\(s?.classesGiven ?? 0)",
                    icon: AppIcons.doc,
                    tint: AppColors.primary)
        }
    }

    private var recentAttendancesSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: AppStrings.lastAttendances)

            if viewModel.pastAttendances.isEmpty && !viewModel.isLoading {
                EmptyState(
                    icon: AppIcons.doc,
                    title: "Sem chamadas anteriores",
                    subtitle: "Suas chamadas mais recentes aparecem aqui."
                )
            } else {
                ForEach(viewModel.pastAttendances) { attendance in
                    PastAttendanceRow(attendance: attendance)
                }
            }
        }
    }
}

private struct PastAttendanceRow: View {
    let attendance: ChamadaPassadaDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: AppIcons.checkCircleFill)
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.success)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(attendance.className)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(attendance.date) · \(attendance.time)\(attendance.classType.map { " · \($0)" } ?? "")")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(attendance.presentCount)/\(attendance.totalCount)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(attendance.presencePercentage)%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.success)
            }
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

#Preview {
    ProfessorHomeView().environmentObject(AuthSession.shared)
}
