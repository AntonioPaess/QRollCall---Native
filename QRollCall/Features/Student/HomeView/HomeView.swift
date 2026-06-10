//
//  HomeView.swift
//  QRollCall
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var viewModel = StudentHomeViewModel()
    @State private var selectedAttendance: ChamadaAtivaDTO?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                    PremiumHeader(
                        greeting: AppStrings.greeting,
                        title: auth.firstName.isEmpty ? auth.fullName : auth.firstName
                    )

                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.danger)
                    }

                    if let active = viewModel.firstActiveAttendance {
                        liveAttendanceBanner(active)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.94).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    nextClassCard
                    statsGrid
                    recentActivitySection
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
                .animation(.spring(duration: 0.4), value: viewModel.firstActiveAttendance?.id)
            }
            .background(AppColors.background)
            .navigationBarHidden(true)
            .refreshable { await viewModel.load() }
            .task {
                // Carga inicial + polling leve a cada 5s. Cancela ao sair da tela.
                await viewModel.load()
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    if Task.isCancelled { break }
                    await viewModel.pollActiveAttendances()
                }
            }
            .fullScreenCover(item: $selectedAttendance, onDismiss: {
                Task { await viewModel.load() }
            }) { attendance in
                AttendanceFlowView(attendance: attendance)
            }
        }
    }

    // MARK: - Live attendance banner

    private func liveAttendanceBanner(_ active: ChamadaAtivaDTO) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            selectedAttendance = active
        } label: {
            HStack(spacing: AppDimens.spacingMD) {
                LivePulse(color: AppColors.success)

                VStack(alignment: .leading, spacing: 3) {
                    Text(active.materiaNome.isEmpty ? AppStrings.activeAttendance : active.materiaNome)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text(AppStrings.tapToRegister)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.success)
            }
            .padding(AppDimens.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.success.opacity(0.10))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(AppColors.success.opacity(0.45), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Next class

    private var nextClassCard: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: 6) {
                Image(systemName: AppIcons.clock)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
                Text(AppStrings.nextClass.uppercased())
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

                HStack(spacing: AppDimens.spacingMD) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(AppColors.surfaceMuted).frame(height: 4)
                            Capsule()
                                .fill(AppColors.primary)
                                .frame(width: geo.size.width * next.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    Text(next.timeUntil)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize()
                }
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

    // MARK: - Stats grid

    private var statsGrid: some View {
        let s = viewModel.stats
        return LazyVGrid(
            columns: [GridItem(.flexible(), spacing: AppDimens.spacingMD),
                      GridItem(.flexible(), spacing: AppDimens.spacingMD)],
            spacing: AppDimens.spacingMD
        ) {
            KPICard(title: AppStrings.presence,
                    value: "\(s?.presencePercentage ?? 0)%",
                    icon: AppIcons.chartUp,
                    tint: AppColors.success)
            KPICard(title: AppStrings.classes,
                    value: "\(s?.totalClasses ?? 0)",
                    icon: AppIcons.checkCircle,
                    tint: AppColors.primary)
            KPICard(title: AppStrings.absences,
                    value: "\(s?.absences ?? 0)",
                    icon: AppIcons.xCircle,
                    tint: AppColors.danger)
            KPICard(title: AppStrings.streak,
                    value: "\(s?.streakDays ?? 0)",
                    icon: AppIcons.flame,
                    tint: AppColors.warning)
        }
    }

    // MARK: - Recent activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: AppStrings.recentActivity)

            if viewModel.activities.isEmpty && !viewModel.isLoading {
                EmptyState(
                    icon: AppIcons.clock,
                    title: "Sem atividades recentes",
                    subtitle: "Suas confirmações aparecerão aqui."
                )
            } else {
                ForEach(viewModel.activities) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
}

// MARK: - Live Pulse

private struct LivePulse: View {
    let color: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.30))
                .frame(width: 16, height: 16)
                .scaleEffect(pulse ? 1.8 : 1.0)
                .opacity(pulse ? 0 : 1)
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .frame(width: 16, height: 16)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

// MARK: - Stat Card (legacy)

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    let subtitleColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundStyle(subtitleColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

// MARK: - Activity row

struct ActivityRow: View {
    let activity: AtividadeDTO

    private var statusColor: Color {
        switch activity.status.lowercased() {
        case "presente": return AppColors.success
        case "ausente":  return AppColors.danger
        default:         return AppColors.warning
        }
    }

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: activity.status.lowercased() == "presente"
                          ? AppIcons.checkCircleFill : AppIcons.xCircleFill)
                        .font(.system(size: 16))
                        .foregroundStyle(statusColor)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(activity.className)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(activity.date) · \(activity.time)")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle().fill(statusColor).frame(width: 5, height: 5)
                Text(activity.status)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppColors.surfaceMuted, in: Capsule())
            .overlay { Capsule().strokeBorder(AppColors.hairline, lineWidth: 0.5) }
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

#Preview {
    HomeView().environmentObject(AuthSession.shared)
}
