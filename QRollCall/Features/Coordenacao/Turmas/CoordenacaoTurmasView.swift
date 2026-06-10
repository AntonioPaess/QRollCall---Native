//
//  CoordenacaoTurmasView.swift
//  QRollCall
//
//  Vista de Cursos: cada curso lista os grupos derivados (CC-2024.1, CC-2024.1-A...).
//

import SwiftUI

struct CoordenacaoTurmasView: View {
    @StateObject private var vm = CoordenacaoTurmasViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppDimens.spacingLG) {
                        searchField
                        if vm.isLoading && vm.cursos.isEmpty {
                            ProgressView()
                                .padding(.vertical, AppDimens.spacingXXL)
                        } else if vm.filtered.isEmpty {
                            EmptyState(
                                icon: AppIcons.book,
                                title: "Nenhum curso cadastrado",
                                subtitle: "Cadastre cursos para começar."
                            )
                            .padding(.top, AppDimens.spacingXXL)
                        } else {
                            LazyVStack(spacing: AppDimens.spacingMD) {
                                ForEach(vm.filtered) { curso in
                                    NavigationLink(value: curso) {
                                        CursoRow(curso: curso)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            Task { await vm.removerCurso(id: curso.id) }
                                        } label: {
                                            Label("Excluir \(curso.codigo)", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppDimens.spacingXXL)
                    .padding(.top, AppDimens.spacingLG)
                    .padding(.bottom, AppDimens.spacing4XL)
                }
            }
            .navigationTitle("Cursos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showCreate = true
                    } label: {
                        Image(systemName: AppIcons.plus)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .navigationDestination(for: CursoResponseDTO.self) { curso in
                CursoDetailView(curso: curso)
            }
            .sheet(isPresented: $vm.showCreate) {
                createCursoSheet
            }
            .refreshable { await vm.load() }
            .task { await vm.load() }
        }
    }

    private var searchField: some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.tertiary)
            TextField("Buscar curso", text: $vm.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(AppDimens.spacingMD)
        .background(AppColors.cardBackground,
                    in: RoundedRectangle(cornerRadius: AppDimens.radiusMD, style: .continuous))
    }

    private var createCursoSheet: some View {
        NavigationStack {
            Form {
                Section("Identificação") {
                    TextField("Código (ex: CC, ENG)", text: $vm.formCodigo)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                    TextField("Nome do curso", text: $vm.formNome)
                }
            }
            .navigationTitle("Novo curso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { vm.showCreate = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(vm.isSubmitting ? "..." : "Criar") {
                        Task { await vm.criarCurso() }
                    }
                    .disabled(!canSubmit || vm.isSubmitting)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var canSubmit: Bool {
        !vm.formCodigo.trimmingCharacters(in: .whitespaces).isEmpty
            && !vm.formNome.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

private struct LabeledField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, AppDimens.spacingLG)
                .padding(.vertical, AppDimens.spacingMD)
                .background(AppColors.cardBackground,
                            in: RoundedRectangle(cornerRadius: AppDimens.radiusMD, style: .continuous))
        }
    }
}

private struct CursoRow: View {
    let curso: CursoResponseDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingLG) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 44, height: 44)
                .overlay {
                    Text(curso.codigo)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppColors.primaryStrong)
                }
            VStack(alignment: .leading, spacing: 3) {
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

// MARK: - Curso Detail (tabs internas: Matérias, Turmas, Alunos)

enum CursoTab: String, CaseIterable, Identifiable {
    case materias, turmas, alunos, professores
    var id: String { rawValue }
    var label: String {
        switch self {
        case .materias:    return "Matérias"
        case .turmas:      return "Turmas"
        case .alunos:      return "Alunos"
        case .professores: return "Professores"
        }
    }
}

struct CursoDetailView: View {
    let curso: CursoResponseDTO

    @Environment(\.dismiss) private var dismiss
    @State private var tab: CursoTab = .turmas
    @State private var grupos: [GrupoDTO] = []
    @State private var materias: [MateriaListDTO] = []
    @State private var alunos: [AlunoBuscaDTO] = []
    @State private var professores: [ProfessorListDTO] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCreateAluno = false
    @State private var showCreateMateria = false
    @State private var showCreateProfessor = false
    @State private var showCreateTurma = false
    @State private var confirmDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                header
                tabsPicker
                content
                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.danger)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .background(AppColors.background)
        .navigationTitle(curso.codigo)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Button {
                            switch tab {
                            case .materias:    showCreateMateria = true
                            case .professores: showCreateProfessor = true
                            case .turmas:      showCreateTurma = true
                            case .alunos:      showCreateAluno = true
                            }
                        } label: {
                            switch tab {
                            case .materias:
                                Label("Nova matéria", systemImage: AppIcons.doc)
                            case .professores:
                                Label("Novo professor", systemImage: AppIcons.person)
                            case .turmas:
                                Label("Nova turma", systemImage: AppIcons.classes)
                            case .alunos:
                                Label("Novo aluno", systemImage: AppIcons.people)
                            }
                        }
                    }
                    Section {
                        Button(role: .destructive) {
                            confirmDelete = true
                        } label: {
                            Label("Excluir curso", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: AppIcons.plus)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .navigationDestination(for: GrupoDTO.self) { g in
            GrupoDetailView(grupo: g)
        }
        .navigationDestination(for: Int64.self) { alunoId in
            AlunoDetailView(alunoId: alunoId)
        }
        .navigationDestination(for: MateriaNavId.self) { nav in
            MateriaDetailView(materiaId: nav.id)
        }
        .sheet(isPresented: $showCreateAluno) {
            CadastrarAlunoSheet(curso: curso) {
                Task { await load() }
            }
        }
        .sheet(isPresented: $showCreateMateria) {
            CreateMateriaForCursoSheet(cursoId: curso.id) {
                Task { await load() }
            }
        }
        .sheet(isPresented: $showCreateProfessor) {
            CadastrarProfessorSheet {
                Task { await load() }
            }
        }
        .sheet(isPresented: $showCreateTurma) {
            NovaTurmaSheet(curso: curso) {
                Task { await load() }
            }
        }
        .confirmationDialog(
            "Excluir curso?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Excluir \(curso.codigo)", role: .destructive) {
                Task {
                    try? await CoordenacaoService.removerCurso(id: curso.id)
                    dismiss()
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Essa ação remove o curso e suas associações. Não pode ser desfeita.")
        }
        .task { await load() }
        .refreshable { await load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
            VStack(alignment: .leading, spacing: 4) {
                Text(curso.codigo)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.primaryStrong)
                    .tracking(0.5)
                Text(curso.nome)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            HStack(spacing: 0) {
                StatPill(value: "\(curso.totalAlunos)", label: "alunos")
                Spacer()
                Divider().frame(height: 28)
                Spacer()
                StatPill(value: "\(curso.totalMaterias)", label: "matérias")
                Spacer()
                Divider().frame(height: 28)
                Spacer()
                StatPill(value: "\(grupos.count)", label: "turmas")
                Spacer()
                Divider().frame(height: 28)
                Spacer()
                StatPill(value: "\(professores.count)", label: "profs")
            }
        }
        .padding(AppDimens.spacingXL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .minimalCard(corner: 16)
    }

    private var tabsPicker: some View {
        Picker("", selection: $tab) {
            ForEach(CursoTab.allCases) { Text($0.label).tag($0) }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder private var content: some View {
        if isLoading && grupos.isEmpty && materias.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppDimens.spacingXXL)
        } else {
            switch tab {
            case .materias:    materiasTab
            case .turmas:      turmasTab
            case .alunos:      alunosTab
            case .professores: professoresTab
            }
        }
    }

    @ViewBuilder private var professoresTab: some View {
        if professores.isEmpty {
            EmptyState(icon: AppIcons.person,
                       title: "Nenhum professor associado",
                       subtitle: "Cadastre um professor e associe-o a uma matéria.")
        } else {
            LazyVStack(spacing: AppDimens.spacingSM) {
                ForEach(professores) { p in
                    professorRow(p)
                }
            }
        }
    }

    private func professorRow(_ p: ProfessorListDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: initialsOf(p.nome), size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(p.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 4) {
                    if let ra = p.ra, !ra.isEmpty { Text("RA \(ra)") }
                    if let dep = p.department, !dep.isEmpty {
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

    @ViewBuilder private var materiasTab: some View {
        if materias.isEmpty {
            EmptyState(icon: AppIcons.doc,
                       title: "Sem matérias",
                       subtitle: "Cadastre matérias na tab Matérias.")
        } else {
            LazyVStack(spacing: AppDimens.spacingSM) {
                ForEach(materias) { m in
                    NavigationLink(value: MateriaNavId(id: m.id)) {
                        materiaRow(m)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var turmasTab: some View {
        if grupos.isEmpty {
            EmptyState(icon: AppIcons.people,
                       title: "Sem turmas",
                       subtitle: "As turmas aparecem quando há alunos cadastrados.")
        } else {
            LazyVStack(spacing: AppDimens.spacingMD) {
                ForEach(grupos) { g in
                    NavigationLink(value: g) {
                        GrupoRow(grupo: g)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder private var alunosTab: some View {
        if alunos.isEmpty {
            EmptyState(icon: AppIcons.people,
                       title: "Nenhum aluno cadastrado",
                       subtitle: "Toque em + para criar um aluno.")
        } else {
            LazyVStack(spacing: AppDimens.spacingSM) {
                ForEach(alunos) { a in
                    NavigationLink(value: a.alunoId) {
                        alunoCursoRow(a)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func alunoCursoRow(_ a: AlunoBuscaDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Avatar(initials: initialsOf(a.nome), size: 40)
            VStack(alignment: .leading, spacing: 3) {
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
            Image(systemName: AppIcons.chevronRight)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }

    private func initialsOf(_ s: String) -> String {
        let parts = s.split(separator: " ", maxSplits: 1)
        let f = parts.first?.first.map(String.init) ?? ""
        let l = parts.count > 1 ? parts[1].first.map(String.init) ?? "" : ""
        return "\(f)\(l)".uppercased()
    }

    private func materiaRow(_ m: MateriaListDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: AppIcons.doc)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
                }
            VStack(alignment: .leading, spacing: 2) {
                Text(m.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 4) {
                    if let codigo = m.codigo { Text(codigo) }
                    if let ch = m.cargaHoraria {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text("\(ch)h")
                    }
                }
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Text("\(m.totalAlunos)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.surfaceMuted, in: Capsule())
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        do { grupos = try await CoordenacaoService.listarGrupos(cursoId: curso.id) }
        catch { grupos = [] }
        do { materias = try await CoordenacaoService.listarMaterias(cursoId: curso.id) }
        catch { materias = [] }
        do { alunos = try await CoordenacaoService.alunosDoCurso(cursoId: curso.id) }
        catch { alunos = [] }
        do { professores = try await CoordenacaoService.professoresDoCurso(cursoId: curso.id) }
        catch { professores = [] }
    }
}

// MARK: - Cadastrar aluno (sheet)

private struct CadastrarAlunoSheet: View {
    let curso: CursoResponseDTO
    let onCreated: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var ra = ""
    @State private var anoIngresso = ""
    @State private var subturma = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?

    private var canSubmit: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty
            && !email.trimmingCharacters(in: .whitespaces).isEmpty
            && !senha.isEmpty
            && !ra.trimmingCharacters(in: .whitespaces).isEmpty
            && !anoIngresso.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dados do aluno") {
                    TextField("Nome completo", text: $nome)
                    TextField("E-mail", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Senha inicial", text: $senha)
                    TextField("RA / Matrícula", text: $ra)
                }
                Section("Turma") {
                    HStack {
                        Text("Curso")
                        Spacer()
                        Text(curso.codigo)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    TextField("Ano de ingresso (2024.1)", text: $anoIngresso)
                        .keyboardType(.decimalPad)
                    TextField("Subturma (A, B, C…)", text: $subturma)
                        .textInputAutocapitalization(.characters)
                }
                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(AppColors.danger) }
                }
            }
            .navigationTitle("Novo aluno")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isSubmitting ? "..." : "Cadastrar") { Task { await submit() } }
                        .disabled(!canSubmit || isSubmitting)
                }
            }
        }
    }

    private func submit() async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            let dto = RegisterAlunoFormDTO(
                username: nome.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: senha,
                faceId: nil,
                raAluno: ra.trimmingCharacters(in: .whitespaces),
                anoIngresso: anoIngresso.trimmingCharacters(in: .whitespaces),
                subturma: subturma.trimmingCharacters(in: .whitespaces).isEmpty
                    ? nil : subturma.uppercased(),
                cursoId: curso.id
            )
            try await CoordenacaoService.registrarAluno(dto)
            onCreated()
            dismiss()
        } catch {
            errorMessage = "Erro ao cadastrar. Verifique se o e-mail/RA já existe."
        }
    }
}

private struct StatPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

private struct GrupoRow: View {
    let grupo: GrupoDTO

    var body: some View {
        HStack(spacing: AppDimens.spacingLG) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(AppColors.surfaceMuted)
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: AppIcons.classes)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.primaryStrong)
                }
            VStack(alignment: .leading, spacing: 3) {
                Text(grupo.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(grupo.totalAlunos) aluno\(grupo.totalAlunos == 1 ? "" : "s") · Ingresso \(grupo.anoIngresso)")
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

// MARK: - Grupo Detail (alunos + métricas do grupo)

struct GrupoDetailView: View {
    let grupo: GrupoDTO

    @State private var resumo: TurmaResumoDTO?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppDimens.spacingXXL)
                } else if let resumo {
                    headerCard(resumo)
                    SectionHeader(title: "Alunos")
                    if resumo.alunos.isEmpty {
                        EmptyState(icon: AppIcons.people, title: "Nenhum aluno nesta turma")
                    } else {
                        LazyVStack(spacing: AppDimens.spacingMD) {
                            ForEach(resumo.alunos) { aluno in
                                NavigationLink(value: aluno.alunoId) {
                                    AlunoRiscoRow(aluno: aluno)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                        .padding(.top, AppDimens.spacingXXL)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .background(AppColors.background)
        .navigationTitle(grupo.label)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Int64.self) { alunoId in
            AlunoDetailView(alunoId: alunoId)
        }
        .task { await load() }
    }

    private func headerCard(_ r: TurmaResumoDTO) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Turma")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.primaryStrong)
                    .tracking(0.5)
                Text("Ingresso \(grupo.anoIngresso)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                StatPill2(value: "\(r.totalAlunos)", label: "alunos")
                Spacer()
                Divider().frame(height: 28)
                Spacer()
                StatPill2(value: "\(r.alunosEmRisco)", label: "em risco", accent: AppColors.warning)
                Spacer()
                Divider().frame(height: 28)
                Spacer()
                StatPill2(value: "\(r.alunosReprovados)", label: "reprovados", accent: AppColors.danger)
            }
        }
        .padding(AppDimens.spacingXL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .minimalCard(corner: 16)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            resumo = try await MetricasService.resumoGrupo(
                cursoId: grupo.cursoId,
                anoIngresso: grupo.anoIngresso,
                subturma: grupo.subturma
            )
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar."
        }
    }
}

private struct StatPill2: View {
    let value: String
    let label: String
    var accent: Color = AppColors.textPrimary

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

private struct AlunoRiscoRow: View {
    let aluno: AlunoResumoDTO

    private var worstStatus: StatusFrequencia {
        if aluno.materiasReprovadas > 0 { return .reprovado }
        if aluno.materiasEmRisco > 0 { return .emRisco }
        let any = aluno.materias.contains(where: { $0.status == .alerta })
        return any ? .alerta : .ok
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(aluno.nome)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    if let ra = aluno.ra {
                        Text("RA \(ra)")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                Spacer()
                StatusBadge(status: worstStatus)
            }
            if !aluno.materias.isEmpty {
                VStack(spacing: AppDimens.spacingSM) {
                    ForEach(aluno.materias.prefix(3)) { m in
                        HStack {
                            Text(m.materiaNome)
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.textSecondary)
                                .lineLimit(1)
                            Spacer()
                            Text("\(m.faltas)/\(m.limite)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(StatusBadgeColor.color(m.status))
                        }
                    }
                    if aluno.materias.count > 3 {
                        Text("+ \(aluno.materias.count - 3) outras")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

/// Wrapper para diferenciar navegação de Aluno (Int64) e Matéria (Int64) no mesmo NavigationStack.
struct MateriaNavId: Hashable {
    let id: Int64
}

enum StatusBadgeColor {
    static func color(_ s: StatusFrequencia) -> Color {
        switch s {
        case .ok:        return AppColors.success
        case .alerta:    return AppColors.warning
        case .emRisco:   return AppColors.warning
        case .reprovado: return AppColors.danger
        }
    }
}

#Preview {
    CoordenacaoTurmasView()
}
