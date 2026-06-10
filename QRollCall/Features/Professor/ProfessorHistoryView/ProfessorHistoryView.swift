//
//  ProfessorHistoryView.swift
//  QRollCall
//

import SwiftUI

struct ProfessorHistoryView: View {
    @StateObject private var viewModel = ProfessorHistoryViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
                    Text(AppStrings.professorHistorySubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textSecondary)

                    filterMenu
                    summaryCard
                    attendancesList
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
                .padding(.bottom, AppDimens.spacing4XL)
            }
            .background(AppColors.background)
            .navigationTitle(AppStrings.historyTitle)
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.load() }
            .refreshable { await viewModel.load() }
        }
    }

    private var filterMenu: some View {
        Menu {
            ForEach(viewModel.availableFilters, id: \.self) { filter in
                Button {
                    viewModel.selectedFilter = filter
                } label: {
                    HStack {
                        Text(filter)
                        if viewModel.selectedFilter == filter {
                            Image(systemName: AppIcons.checkCircleFill)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: AppDimens.spacingMD) {
                Image(systemName: AppIcons.filter)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text(viewModel.selectedFilter)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: AppIcons.chevronDown)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .padding(.horizontal, AppDimens.spacingLG)
            .padding(.vertical, 14)
            .minimalCard()
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 0) {
            summaryColumn(value: "\(viewModel.filtered.count)", label: AppStrings.classesGiven)
            Rectangle().fill(AppColors.hairline).frame(width: 1, height: 32)
            summaryColumn(value: "\(viewModel.averageRate)%",
                          label: AppStrings.averagePresence,
                          accent: AppColors.primaryStrong)
        }
        .padding(.vertical, AppDimens.spacingLG)
        .frame(maxWidth: .infinity)
        .minimalCard()
    }

    private func summaryColumn(value: String, label: String, accent: Color = AppColors.textPrimary) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var attendancesList: some View {
        VStack(spacing: AppDimens.spacingMD) {
            if viewModel.filtered.isEmpty && !viewModel.isLoading {
                EmptyState(
                    icon: AppIcons.doc,
                    title: "Sem chamadas registradas",
                    subtitle: "As chamadas que você fizer aparecem aqui."
                )
            } else {
                ForEach(viewModel.filtered) { attendance in
                    NavigationLink(destination: AttendanceDetailView(attendance: attendance)) {
                        row(attendance)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func row(_ attendance: ChamadaPassadaDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: AppIcons.doc)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
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

            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

#Preview {
    ProfessorHistoryView()
}
