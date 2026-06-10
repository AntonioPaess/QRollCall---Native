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
                modeSelector
                if viewModel.viewMode == .todas {
                    filterDropdown
                    summaryCard
                    entriesList
                } else {
                    faltasPorMateriaSection
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingXL)
            .padding(.bottom, AppDimens.spacingXXL)
        }
        .background(AppColors.background)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    // MARK: - Mode Selector

    private var modeSelector: some View {
        Picker("", selection: $viewModel.viewMode) {
            ForEach(HistoryViewMode.allCases) { mode in
                Text(mode.label).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Faltas por matéria (3/15)

    private var faltasPorMateriaSection: some View {
        VStack(spacing: AppDimens.spacingMD) {
            if viewModel.isLoading && viewModel.faltasPorMateria.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppDimens.spacingXXL)
            } else if viewModel.faltasPorMateria.isEmpty {
                EmptyState(icon: AppIcons.book,
                           title: "Sem matérias",
                           subtitle: "Suas matérias aparecerão aqui.")
            } else {
                ForEach(viewModel.faltasPorMateria) { item in
                    FaltasMateriaRow(item: item)
                }
            }
        }
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
            HStack(spacing: AppDimens.spacingMD) {
                Image(systemName: AppIcons.filter)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                Text(viewModel.filter.rawValue)
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

    // MARK: - Summary Card

    private var summaryCard: some View {
        HStack(spacing: 0) {
            SummaryColumn(value: "\(viewModel.summary?.presences ?? 0)", label: AppStrings.presences)
            divider
            SummaryColumn(value: "\(viewModel.summary?.absences ?? 0)", label: AppStrings.absences)
            divider
            SummaryColumn(value: "\(viewModel.summary?.rate ?? 0)%", label: AppStrings.rate, accent: AppColors.primaryStrong)
        }
        .padding(.vertical, AppDimens.spacingXL)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColors.hairline, lineWidth: 0.5)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.hairline)
            .frame(width: 1, height: 32)
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
    var accent: Color = AppColors.textPrimary

    var body: some View {
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
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.className)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)

                Text("\(entry.date) · \(entry.time) · \(entry.sala)")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 5, height: 5)
                Text(statusText)
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

// MARK: - Faltas por matéria row

private struct FaltasMateriaRow: View {
    let item: FaltasPorMateriaDTO

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(alignment: .center, spacing: AppDimens.spacingMD) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppColors.surfaceMuted)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: AppIcons.book)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.primaryStrong)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.materiaNome)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    if let ch = item.cargaHoraria {
                        Text("\(ch)h")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            FaltasProgressBar(faltas: item.faltas, limite: item.limite, status: item.status)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

#Preview {
    HistoryView()
}
