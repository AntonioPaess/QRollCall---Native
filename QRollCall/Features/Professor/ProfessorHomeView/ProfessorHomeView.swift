//
//  ProfessorHomeView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ProfessorHomeView: View {
    @EnvironmentObject private var auth: AuthSession
    @StateObject private var viewModel = ProfessorHomeViewModel()
    @State private var showCreateAttendance = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                mainContent
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background)
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

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: AppColors.headerGradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: AppDimens.headerHeight)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(AppStrings.greeting)
                        .font(.system(size: AppDimens.fontCallout, weight: .regular))
                        .foregroundColor(.white.opacity(0.85))
                    Text("Prof. \(viewModel.perfil?.firstName ?? auth.firstName)")
                        .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: AppDimens.avatarSize, height: AppDimens.avatarSize)
                    Text(auth.initials.isEmpty ? "?" : auth.initials)
                        .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.bottom, 70)

            startAttendanceCard
                .offset(y: 45)
        }
        .padding(.bottom, 55)
    }

    private var startAttendanceCard: some View {
        Button {
            showCreateAttendance = true
        } label: {
            HStack(spacing: AppDimens.spacingLG) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppDimens.radiusMD)
                        .fill(AppColors.primaryOpacity(0.12))
                        .frame(width: AppDimens.qrIconContainerSize, height: AppDimens.qrIconContainerSize)
                    Image(systemName: AppIcons.play)
                        .font(.system(size: AppDimens.iconXXL, weight: .medium))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                    Text(AppStrings.startAttendance)
                        .font(.system(size: AppDimens.fontTitle3, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(AppStrings.startAttendanceSubtitle)
                        .font(.system(size: AppDimens.fontSmall, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: AppDimens.iconXL))
                    .foregroundColor(AppColors.primaryOpacity(0.5))
            }
            .padding(AppDimens.spacingXL)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppDimens.spacingXXL)
    }

    private var mainContent: some View {
        VStack(spacing: AppDimens.spacingXL) {
            if let msg = viewModel.errorMessage {
                Text(msg)
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.error)
            }
            nextClassCard
            statsRow
            recentAttendancesSection
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .padding(.bottom, AppDimens.spacingXXL)
    }

    private var nextClassCard: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingSM) {
                Image(systemName: AppIcons.clock)
                    .font(.system(size: AppDimens.iconMD))
                    .foregroundColor(AppColors.primary)
                Text(AppStrings.currentClass)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }

            if let next = viewModel.nextClass {
                Text(next.nome)
                    .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(next.startTime) - \(next.endTime) • \(next.sala)")
                    .font(.system(size: AppDimens.fontBody, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: AppDimens.spacingSM) {
                    Image(systemName: AppIcons.people)
                        .font(.system(size: AppDimens.iconSM))
                        .foregroundColor(AppColors.primary)
                    Text("\(next.totalStudents) \(AppStrings.students)")
                        .font(.system(size: AppDimens.fontCaption, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            } else {
                Text("Sem aulas agendadas")
                    .font(.system(size: AppDimens.fontBody, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppDimens.spacingXL)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private var statsRow: some View {
        let s = viewModel.stats
        return HStack(spacing: AppDimens.spacingMD) {
            StatCard(
                icon: AppIcons.chartUp,
                iconColor: AppColors.success,
                title: AppStrings.averagePresence,
                value: "\(s?.averagePresence ?? 0)%",
                subtitle: AppStrings.thisSemester,
                subtitleColor: AppColors.success
            )
            StatCard(
                icon: AppIcons.doc,
                iconColor: AppColors.primary,
                title: AppStrings.classesGiven,
                value: "\(s?.classesGiven ?? 0)",
                subtitle: AppStrings.thisSemester,
                subtitleColor: AppColors.textSecondary
            )
        }
    }

    private var recentAttendancesSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Text(AppStrings.lastAttendances)
                .font(.system(size: AppDimens.fontTitle2, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            if viewModel.pastAttendances.isEmpty && !viewModel.isLoading {
                Text("Sem chamadas anteriores.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
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
        HStack(spacing: AppDimens.spacingSM + 6) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryOpacity(0.12))
                    .frame(width: AppDimens.activityIconSize, height: AppDimens.activityIconSize)
                Image(systemName: AppIcons.checkCircleFill)
                    .font(.system(size: AppDimens.iconLG))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(attendance.className)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Text("\(attendance.date) • \(attendance.time)\(attendance.classType.map { " • \($0)" } ?? "")")
                    .font(.system(size: AppDimens.fontCaption, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(attendance.presentCount)/\(attendance.totalCount)")
                    .font(.system(size: AppDimens.fontSmall, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text("\(attendance.presencePercentage)%")
                    .font(.system(size: AppDimens.fontCaption, weight: .medium))
                    .foregroundColor(AppColors.success)
            }
        }
        .padding(AppDimens.spacingLG)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    ProfessorHomeView().environmentObject(AuthSession.shared)
}
