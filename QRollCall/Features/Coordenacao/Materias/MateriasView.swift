//
//  MateriasView.swift
//  QRollCall
//

import SwiftUI

struct MateriasView: View {
    @StateObject private var vm = MateriasViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppDimens.spacingLG) {
                        searchField

                        if vm.isLoading && vm.materias.isEmpty {
                            ProgressView()
                                .padding(.vertical, AppDimens.spacingXXL)
                        } else if vm.materias.isEmpty {
                            EmptyState(
                                icon: AppIcons.doc,
                                title: "Nenhuma matéria cadastrada",
                                subtitle: "Toque em + para criar."
                            )
                            .padding(.top, AppDimens.spacingXXL)
                        } else {
                            ForEach(vm.grouped, id: \.0) { cursoNome, mats in
                                VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
                                    SectionHeader(title: cursoNome)
                                    LazyVStack(spacing: AppDimens.spacingSM) {
                                        ForEach(mats) { m in
                                            NavigationLink(value: m.id) {
                                                MateriaRow(materia: m)
                                            }
                                            .buttonStyle(.plain)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    Task {
                                                        try? await CoordenacaoService.removerMateria(id: m.id)
                                                        await vm.load()
                                                    }
                                                } label: {
                                                    Label("Excluir matéria", systemImage: "trash")
                                                }
                                            }
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
            .navigationTitle("Matérias")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.resetForm()
                        vm.showCreate = true
                    } label: {
                        Image(systemName: AppIcons.plus)
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .navigationDestination(for: Int64.self) { materiaId in
                MateriaDetailView(materiaId: materiaId)
            }
            .sheet(isPresented: $vm.showCreate) {
                MateriaCreateSheet(vm: vm)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .refreshable { await vm.load() }
            .task { await vm.load() }
        }
    }

    private var searchField: some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textTertiary)
            TextField("Buscar matéria", text: $vm.search)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(AppDimens.spacingMD)
        .minimalCard()
    }
}

private struct MateriaRow: View {
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
            VStack(alignment: .leading, spacing: 3) {
                Text(materia.nome)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                HStack(spacing: 6) {
                    if let codigo = materia.codigo, !codigo.isEmpty {
                        Text(codigo)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if let ch = materia.cargaHoraria {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text("\(ch)h")
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if let p = materia.periodoNome {
                        Text("·").foregroundStyle(AppColors.textTertiary)
                        Text(p)
                            .font(.system(size: 11))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Spacer(minLength: 0)
                }
            }
            Spacer()
            Text("\(materia.totalAlunos)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppColors.surfaceMuted, in: Capsule())
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

private struct MateriaCreateSheet: View {
    @ObservedObject var vm: MateriasViewModel
    @State private var novoPeriodoNome = ""
    @State private var showAddPeriodo = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Dados") {
                    TextField("Nome", text: $vm.formNome)
                    TextField("Código (ex: POO)", text: $vm.formCodigo)
                        .textInputAutocapitalization(.characters)
                    TextField("Sala", text: $vm.formSala)
                }
                Section("Carga horária") {
                    Picker("Carga horária", selection: $vm.formCargaHoraria) {
                        Text("45h (1 dia = 3 faltas)").tag(45)
                        Text("60h (1 dia = 2 faltas)").tag(60)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                Section("Curso") {
                    if vm.cursos.isEmpty {
                        Text("Cadastre um curso antes")
                            .foregroundStyle(AppColors.textSecondary)
                    } else {
                        Picker("Curso", selection: $vm.formCursoId) {
                            Text("—").tag(Int64?.none)
                            ForEach(vm.cursos) { c in
                                Text("\(c.codigo) · \(c.nome)").tag(Int64?.some(c.id))
                            }
                        }
                    }
                }
                Section("Período") {
                    if vm.periodos.isEmpty {
                        HStack {
                            TextField("Ex: 1º semestre", text: $novoPeriodoNome)
                            Button("Criar") {
                                Task {
                                    await vm.criarPeriodoRapido(nome: novoPeriodoNome)
                                    novoPeriodoNome = ""
                                }
                            }
                            .disabled(novoPeriodoNome.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    } else {
                        Picker("Período", selection: $vm.formPeriodoId) {
                            ForEach(vm.periodos) { p in
                                Text(p.nome).tag(Int64?.some(p.id))
                            }
                        }
                        Button("Adicionar período") { showAddPeriodo = true }
                            .font(.system(size: 13))
                    }
                }
            }
            .navigationTitle("Nova matéria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { vm.showCreate = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(vm.isSubmitting ? "..." : "Criar") {
                        Task { await vm.criar() }
                    }
                    .disabled(!vm.canSubmit || vm.isSubmitting)
                }
            }
            .alert("Adicionar período", isPresented: $showAddPeriodo) {
                TextField("Nome", text: $novoPeriodoNome)
                Button("Criar") {
                    Task {
                        await vm.criarPeriodoRapido(nome: novoPeriodoNome)
                        novoPeriodoNome = ""
                    }
                }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }
}

#Preview {
    MateriasView()
}
