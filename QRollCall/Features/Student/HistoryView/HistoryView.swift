//
//  HistoryView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct HistoryView: View {
    @State private var selectedFilter: HistoryFilter = .todas

    private let summary = HistoryMockData.summary
    private let entries = HistoryMockData.entries

    private var filteredEntries: [HistoryEntry] {
        switch selectedFilter {
        case .todas:
            return entries
        case .presente:
            return entries.filter { $0.status == .presente }
        case .ausente:
            return entries.filter { $0.status == .ausente }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                headerSection
                filterDropdown
                summaryCard
                entriesList
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingXL)
            .padding(.bottom, AppDimens.spacingXXL)
        }
        .background(AppColors.background)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
            Text(AppStrings.historyTitle)
                .font(.system(size: AppDimens.fontLargeTitle, weight: .bold))
                .foregroundColor(AppColors.textPrimary)

            Text(AppStrings.historySubtitle)
                .font(.system(size: AppDimens.fontBody, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Filter Dropdown

    private var filterDropdown: some View {
        Menu {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    HStack {
                        Text(filter.rawValue)
                        if selectedFilter == filter {
                            Image(systemName: AppIcons.checkCircleFill)
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: AppIcons.filter)
                    .font(.system(size: AppDimens.iconMD, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)

                Text(selectedFilter.rawValue)
                    .font(.system(size: AppDimens.fontCallout, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Image(systemName: AppIcons.chevronDown)
                    .font(.system(size: AppDimens.iconSM, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, AppDimens.spacingXL)
            .padding(.vertical, AppDimens.spacingLG)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        HStack(spacing: 0) {
            SummaryColumn(value: "\(summary.presences)", label: AppStrings.presences)

            divider

            SummaryColumn(value: "\(summary.absences)", label: AppStrings.absences)

            divider

            SummaryColumn(value: "\(summary.rate)%", label: AppStrings.rate)
        }
        .padding(.vertical, AppDimens.spacingXL)
        .background(
            LinearGradient(
                colors: [AppColors.primary, AppColors.purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusLG))
        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, y: 4)
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 40)
    }

    // MARK: - Entries List

    private var entriesList: some View {
        VStack(spacing: AppDimens.spacingMD) {
            ForEach(filteredEntries) { entry in
                HistoryEntryRow(entry: entry)
            }
        }
    }
}

// MARK: - Summary Column

private struct SummaryColumn: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: AppDimens.spacingXS) {
            Text(value)
                .font(.system(size: AppDimens.fontTitle1, weight: .bold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: AppDimens.fontCaption, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - History Entry Row

private struct HistoryEntryRow: View {
    let entry: HistoryEntry

    private var statusColor: Color {
        switch entry.status {
        case .presente: return AppColors.success
        case .ausente: return AppColors.error
        case .justificado: return AppColors.warning
        }
    }

    private var statusText: String {
        switch entry.status {
        case .presente: return AppStrings.present
        case .ausente: return "Falta"
        case .justificado: return AppStrings.justified
        }
    }

    private var statusIcon: String {
        switch entry.status {
        case .presente: return AppIcons.checkCircleFill
        case .ausente, .justificado: return AppIcons.xCircleFill
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                Text(entry.className)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(entry.date) • \(entry.time) • \(entry.room)")
                    .font(.system(size: AppDimens.fontCaption, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: AppDimens.spacingXS) {
                Image(systemName: statusIcon)
                    .font(.system(size: AppDimens.iconSM))
                    .foregroundColor(statusColor)

                Text(statusText)
                    .font(.system(size: AppDimens.fontCaption, weight: .semibold))
                    .foregroundColor(statusColor)
            }
            .padding(.horizontal, AppDimens.spacingMD)
            .padding(.vertical, 6)
            .background(statusColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(AppDimens.spacingLG)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

#Preview {
    HistoryView()
}
