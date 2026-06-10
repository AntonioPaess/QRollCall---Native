//
//  MateriaDetailView.swift
//  QRollCall
//

import Combine
import SwiftUI

@MainActor
final class MateriaDetailViewModel: ObservableObject {
    let materiaId: Int64
    @Published private(set) var detail: MateriaDetailDTO?
    @Published private(set) var todosProfessores: [ProfessorListDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(materiaId: Int64) { self.materiaId = materiaId }

    var professoresDisponiveis: [ProfessorListDTO] {
        let usados = Set(detail?.professores.map(\.professorId) ?? [])
        return todosProfessores.filter { !usados.contains($0.professorId) }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let dTask = CoordenacaoService.materiaDetail(materiaId: materiaId)
            async let pTask = CoordenacaoService.listarProfessores()
            detail = try await dTask
            todosProfessores = try await pTask
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar."
        }
    }

    func associar(professorId: Int64) async {
        do {
            try await CoordenacaoService.associarProfessorMateria(
                professorId: professorId, materiaId: materiaId
            )
            await load()
        } catch {
            errorMessage = "Erro ao associar professor."
        }
    }

    func desassociar(professorId: Int64) async {
        do {
            try await CoordenacaoService.desassociarProfessorMateria(
                professorId: professorId, materiaId: materiaId
            )
            await load()
        } catch {
            errorMessage = "Erro ao desassociar."
        }
    }

    func matricular(alunoId: Int64) async {
        do {
            try await CoordenacaoService.matricularAluno(alunoId: alunoId, materiaId: materiaId)
            await load()
        } catch {
            errorMessage = "Erro ao matricular aluno."
        }
    }

    func desmatricular(alunoId: Int64) async {
        do {
            try await CoordenacaoService.desmatricularAluno(alunoId: alunoId, materiaId: materiaId)
            await load()
        } catch {
            errorMessage = "Erro ao desmatricular."
        }
    }
}

struct MateriaDetailView: View {
    @StateObject private var vm: MateriaDetailViewModel
    @State private var showAddProfessor = false
    @State private var showAddAluno = false
    @State private var confirmDelete = false
    @Environment(\.dismiss) private var dismiss

    init(materiaId: Int64) {
        _vm = StateObject(wrappedValue: MateriaDetailViewModel(materiaId: materiaId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                if vm.isLoading && vm.detail == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppDimens.spacingXXL)
                } else if let d = vm.detail {
                    headerCard(d)
                    professoresSection(d)
                    alunosSection(d)
                }
                if let err = vm.errorMessage {
                    Text(err).font(.system(size: 13)).foregroundStyle(AppColors.danger)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .background(AppColors.background)
        .navigationTitle(vm.detail?.nome ?? "Matéria")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Excluir matéria", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .confirmationDialog(
            "Excluir matéria?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Excluir", role: .destructive) {
                Task {
                    try? await CoordenacaoService.removerMateria(id: vm.materiaId)
                    dismiss()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Essa ação remove a matéria e suas associações. Não pode ser desfeita.")
        }
        .navigationDestination(for: Int64.self) { alunoId in
            AlunoDetailView(alunoId: alunoId)
        }
        .sheet(isPresented: $showAddProfessor) {
            PickerSheet(
                title: "Adicionar professor",
                items: vm.professoresDisponiveis,
                emptyMessage: "Todos os professores já estão associados.",
                rowLabel: { "\($0.nome)" },
                rowSubtitle: { $0.ra.flatMap { "RA \($0)" } },
                onSelect: { p in
                    Task { await vm.associar(professorId: p.professorId) }
                }
            )
        }
        .sheet(isPresented: $showAddAluno) {
            AlunoSearchPickerSheet { alunoId in
                Task { await vm.matricular(alunoId: alunoId) }
            }
        }
        .task { await vm.load() }
        .refreshable { await vm.load() }
    }

    private func headerCard(_ d: MateriaDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
            VStack(alignment: .leading, spacing: 4) {
                if let codigo = d.codigo, !codigo.isEmpty {
                    Text(codigo)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.primaryStrong)
                        .tracking(0.5)
                }
                Text(d.nome)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 6) {
                    if let cn = d.cursoCodigo { Text(cn) }
                    if let pn = d.periodoNome {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(pn)
                    }
                    if let ch = d.cargaHoraria {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text("\(ch)h")
                    }
                    if let s = d.sala, !s.isEmpty {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(s)
                    }
                }
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .padding(AppDimens.spacingXL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .minimalCard(corner: 16)
    }

    private func professoresSection(_ d: MateriaDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: "Professores",
                          trailing: AnyView(
                            Button {
                                showAddProfessor = true
                            } label: {
                                Image(systemName: AppIcons.plus)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.primary)
                            }
                          ))
            if d.professores.isEmpty {
                EmptyState(icon: AppIcons.person,
                           title: "Nenhum professor associado",
                           subtitle: "Toque em + para adicionar.")
            } else {
                LazyVStack(spacing: AppDimens.spacingSM) {
                    ForEach(d.professores) { p in
                        professorRow(p)
                    }
                }
            }
        }
    }

    private func professorRow(_ p: ProfessorListDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: initials(p.nome), size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(p.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                if let dep = p.department, !dep.isEmpty {
                    Text(dep)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            Spacer()
            Button {
                Task { await vm.desassociar(professorId: p.professorId) }
            } label: {
                Image(systemName: "minus.circle")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.danger)
            }
            .buttonStyle(.plain)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }

    private func alunosSection(_ d: MateriaDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: "Alunos matriculados",
                          subtitle: "\(d.alunos.count) aluno\(d.alunos.count == 1 ? "" : "s")",
                          trailing: AnyView(
                            Button {
                                showAddAluno = true
                            } label: {
                                Image(systemName: AppIcons.plus)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.primary)
                            }
                          ))
            if d.alunos.isEmpty {
                EmptyState(icon: AppIcons.people,
                           title: "Nenhum aluno matriculado")
            } else {
                LazyVStack(spacing: AppDimens.spacingSM) {
                    ForEach(d.alunos) { a in
                        alunoRow(a)
                    }
                }
            }
        }
    }

    private func alunoRow(_ a: AlunoBuscaDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            NavigationLink(value: a.alunoId) {
                HStack(spacing: AppDimens.spacingMD) {
                    Avatar(initials: initials(a.nome), size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(a.nome)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AppColors.textPrimary)
                        if let ra = a.ra, !ra.isEmpty {
                            Text("RA \(ra)")
                                .font(.system(size: 12))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            Button {
                Task { await vm.desmatricular(alunoId: a.alunoId) }
            } label: {
                Image(systemName: "minus.circle")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.danger)
            }
            .buttonStyle(.plain)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }

    private func initials(_ s: String) -> String {
        let parts = s.split(separator: " ", maxSplits: 1)
        let f = parts.first?.first.map(String.init) ?? ""
        let l = parts.count > 1 ? parts[1].first.map(String.init) ?? "" : ""
        return "\(f)\(l)".uppercased()
    }
}

// MARK: - Generic picker sheet

private struct PickerSheet<Item: Identifiable & Hashable>: View {
    let title: String
    let items: [Item]
    let emptyMessage: String
    let rowLabel: (Item) -> String
    let rowSubtitle: (Item) -> String?
    let onSelect: (Item) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    EmptyState(icon: "person.crop.circle.badge.questionmark",
                               title: emptyMessage)
                        .padding(.top, AppDimens.spacingXXL)
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppDimens.spacingSM) {
                            ForEach(items) { item in
                                Button {
                                    onSelect(item)
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(rowLabel(item))
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(AppColors.textPrimary)
                                            if let sub = rowSubtitle(item) {
                                                Text(sub)
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(AppColors.textSecondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: AppIcons.chevronRight)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(AppColors.textTertiary)
                                    }
                                    .padding(AppDimens.spacingLG)
                                    .minimalCard()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, AppDimens.spacingXXL)
                        .padding(.top, AppDimens.spacingLG)
                    }
                }
            }
            .background(AppColors.background)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Aluno search picker (busca + tap matricula)

private struct AlunoSearchPickerSheet: View {
    let onSelect: (Int64) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AlunoSearchPickerVM()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppDimens.spacingMD) {
                    field
                    if vm.isSearching {
                        ProgressView().padding(.top, AppDimens.spacingLG)
                    } else if vm.query.isEmpty {
                        Text("Busque o aluno por nome ou RA")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.top, AppDimens.spacingXXL)
                    } else if vm.results.isEmpty {
                        EmptyState(icon: "person.crop.circle.badge.questionmark",
                                   title: "Nenhum aluno encontrado")
                    } else {
                        LazyVStack(spacing: AppDimens.spacingSM) {
                            ForEach(vm.results) { a in
                                Button {
                                    onSelect(a.alunoId)
                                    dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(a.nome)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(AppColors.textPrimary)
                                            if let ra = a.ra, !ra.isEmpty {
                                                Text("RA \(ra)")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(AppColors.textSecondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: AppIcons.plus)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(AppColors.primary)
                                    }
                                    .padding(AppDimens.spacingLG)
                                    .minimalCard()
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, AppDimens.spacingXXL)
                .padding(.top, AppDimens.spacingLG)
            }
            .background(AppColors.background)
            .navigationTitle("Matricular aluno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
    }

    private var field: some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textTertiary)
            TextField("Nome ou matrícula", text: $vm.query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(AppDimens.spacingMD)
        .minimalCard()
        .task(id: vm.query) {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await vm.search()
        }
    }
}

@MainActor
private final class AlunoSearchPickerVM: ObservableObject {
    @Published var query = ""
    @Published var results: [AlunoBuscaDTO] = []
    @Published var isSearching = false

    func search() async {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { results = []; return }
        isSearching = true
        defer { isSearching = false }
        do {
            let r = try await CoordenacaoService.buscarAlunos(query: q)
            guard q == query.trimmingCharacters(in: .whitespaces) else { return }
            results = r
        } catch is CancellationError {
        } catch {
            results = []
        }
    }
}
