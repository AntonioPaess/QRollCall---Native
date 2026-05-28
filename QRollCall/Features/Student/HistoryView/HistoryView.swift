//
//  HistoryView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = StudentHistoryViewModel()

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
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
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
                    viewModel.filter = filter
                    Task { await viewModel.load() }
                } label: {
                    HStack {
                        Text(filter.rawValue)
                        if viewModel.filter == filter {
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

                Text(viewModel.filter.rawValue)
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
            SummaryColumn(value: "\(viewModel.summary?.presences ?? 0)", label: AppStrings.presences)

            divider

            SummaryColumn(value: "\(viewModel.summary?.absences ?? 0)", label: AppStrings.absences)

            divider

            SummaryColumn(value: "\(viewModel.summary?.rate ?? 0)%", label: AppStrings.rate)
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
            if viewModel.entries.isEmpty && !viewModel.isLoading {
                Text("Sem registros para este filtro.")
                    .font(.system(size: AppDimens.fontCaption))
                    .foregroundColor(AppColors.textSecondary)
            } else {
                ForEach(viewModel.entries) { entry in
                    HistoryEntryRow(entry: entry)
                }
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
    let entry: HistoricoEntryDTO

    private var isPresente: Bool {
        entry.status.lowercased() == "presente"
    }

    private var statusColor: Color {
        isPresente ? AppColors.success : AppColors.error
    }

    private var statusText: String {
        isPresente ? AppStrings.present : "Falta"
    }

    private var statusIcon: String {
        isPresente ? AppIcons.checkCircleFill : AppIcons.xCircleFill
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppDimens.spacingXS) {
                Text(entry.className)
                    .font(.system(size: AppDimens.fontCallout, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text("\(entry.date) • \(entry.time) • \(entry.sala)")
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
