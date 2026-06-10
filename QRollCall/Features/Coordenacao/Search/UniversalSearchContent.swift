//
//  UniversalSearchContent.swift
//  QRollCall
//
//  Busca universal da Coordenação: alunos, professores, matérias e cursos
//  agrupados por seção. Cada row navega ao detail.
//

import Combine
import SwiftUI

@MainActor
final class UniversalSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var results: UniversalSearchDTO = .empty
    @Published private(set) var isSearching = false

    func search() async {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            results = .empty
            return
        }
        isSearching = true
        defer { isSearching = false }
        do {
            let r = try await CoordenacaoService.universalSearch(query: q)
            guard q == query.trimmingCharacters(in: .whitespaces) else { return }
            results = r
        } catch is CancellationError {
            // ignora
        } catch {
            results = .empty
        }
    }
}

private extension UniversalSearchDTO {
    static let empty = UniversalSearchDTO(
        alunos: [], professores: [], materias: [], cursos: []
    )
}

struct UniversalSearchContent: View {
    @StateObject private var vm = UniversalSearchViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                if vm.isSearching && vm.query.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, AppDimens.spacingXXL)
                } else if vm.query.isEmpty {
                    EmptyState(
                        icon: "magnifyingglass",
                        title: "Busca universal",
                        subtitle: "Procure por aluno, matéria, professor ou curso."
                    )
                    .padding(.top, AppDimens.spacingXXL)
                } else if vm.results.isEmpty {
                    EmptyState(
                        icon: "questionmark.circle",
                        title: "Nenhum resultado",
                        subtitle: "Tente outro termo."
                    )
                    .padding(.top, AppDimens.spacingXXL)
                } else {
                    if !vm.results.alunos.isEmpty {
                        section(title: "Alunos") {
                            ForEach(vm.results.alunos) { aluno in
                                NavigationLink(value: SearchNav.aluno(aluno.alunoId)) {
                                    AlunoResultRow(aluno: aluno)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if !vm.results.materias.isEmpty {
                        section(title: "Matérias") {
                            ForEach(vm.results.materias) { m in
                                NavigationLink(value: SearchNav.materia(m.id)) {
                                    MateriaResultRow(materia: m)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    if !vm.results.professores.isEmpty {
                        section(title: "Professores") {
                            ForEach(vm.results.professores) { p in
                                ProfessorResultRow(professor: p)
                            }
                        }
                    }
                    if !vm.results.cursos.isEmpty {
                        section(title: "Cursos") {
                            ForEach(vm.results.cursos) { c in
                                NavigationLink(value: SearchNav.curso(c)) {
                                    CursoResultRow(curso: c)
                                }
                                .buttonStyle(.plain)
                            }
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
        .searchable(text: $vm.query, prompt: "Buscar")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .task(id: vm.query) {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await vm.search()
        }
        .navigationDestination(for: SearchNav.self) { nav in
            switch nav {
            case .aluno(let id):
                AlunoDetailView(alunoId: id)
            case .materia(let id):
                MateriaDetailView(materiaId: id)
            case .curso(let curso):
                CursoDetailView(curso: curso)
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            SectionHeader(title: title)
            VStack(spacing: AppDimens.spacingSM) {
                content()
            }
        }
    }
}

// MARK: - Navigation enum

enum SearchNav: Hashable {
    case aluno(Int64)
    case materia(Int64)
    case curso(CursoResponseDTO)
}

// MARK: - Result rows

private struct AlunoResultRow: View {
    let aluno: AlunoBuscaDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: initials(aluno.nome), size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(aluno.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 4) {
                    if let ra = aluno.ra, !ra.isEmpty { Text("RA \(ra)") }
                    if let email = aluno.email, !email.isEmpty {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(email).lineLimit(1)
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
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

private struct MateriaResultRow: View {
    let materia: MateriaListDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: AppIcons.doc)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(materia.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 4) {
                    if let codigo = materia.codigo, !codigo.isEmpty {
                        Text(codigo)
                    }
                    if let curso = materia.cursoCodigo {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(curso)
                    }
                    if let ch = materia.cargaHoraria {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text("\(ch)h")
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

private struct ProfessorResultRow: View {
    let professor: ProfessorListDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: initials(professor.nome), size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(professor.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 4) {
                    if let ra = professor.ra, !ra.isEmpty { Text("RA \(ra)") }
                    if let dep = professor.department, !dep.isEmpty {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(dep)
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
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

private struct CursoResultRow: View {
    let curso: CursoResponseDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Text(curso.codigo)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.primaryStrong)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(curso.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(curso.totalAlunos) alunos · \(curso.totalMaterias) matérias")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}
