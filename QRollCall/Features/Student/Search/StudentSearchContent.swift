//
//  StudentSearchContent.swift
//  QRollCall
//
//  Busca do aluno: filtra suas matérias (do "3/15") por nome.
//  Mesmo padrão Liquid Glass usado em Coord/Professor.
//

import Combine
import SwiftUI

@MainActor
final class StudentSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var materias: [FaltasPorMateriaDTO] = []
    @Published private(set) var isLoading = false

    var filteredMaterias: [FaltasPorMateriaDTO] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return materias.filter { $0.materiaNome.lowercased().contains(q) }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            materias = try await MetricasService.minhasFaltas()
        } catch {
            materias = []
        }
    }
}

struct StudentSearchContent: View {
    @StateObject private var vm = StudentSearchViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                if vm.query.isEmpty {
                    EmptyState(
                        icon: "magnifyingglass",
                        title: "Buscar nas suas matérias",
                        subtitle: "Digite o nome de uma matéria pra ver suas faltas."
                    )
                    .padding(.top, AppDimens.spacingXXL)
                } else if vm.filteredMaterias.isEmpty {
                    EmptyState(
                        icon: "questionmark.circle",
                        title: "Nenhuma matéria encontrada",
                        subtitle: "Tente outro termo."
                    )
                    .padding(.top, AppDimens.spacingXXL)
                } else {
                    VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
                        SectionHeader(title: "Suas matérias")
                        ForEach(vm.filteredMaterias) { item in
                            MateriaSearchRow(item: item)
                        }
                    }
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, 120)
        }
        .background(AppColors.background)
        .navigationTitle("Buscar")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $vm.query, prompt: "Nome da matéria")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .task { await vm.load() }
    }
}

private struct MateriaSearchRow: View {
    let item: FaltasPorMateriaDTO

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(spacing: AppDimens.spacingMD) {
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
