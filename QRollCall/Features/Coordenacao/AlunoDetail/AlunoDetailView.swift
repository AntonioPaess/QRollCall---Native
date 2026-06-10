//
//  AlunoDetailView.swift
//  QRollCall
//

import SwiftUI

struct AlunoDetailView: View {
    @StateObject private var vm: AlunoDetailViewModel
    @State private var ausenciasMateria: FaltasPorMateriaDTO?

    init(alunoId: Int64) {
        _vm = StateObject(wrappedValue: AlunoDetailViewModel(alunoId: alunoId))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                if vm.isLoading && vm.detail == nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppDimens.spacingXXL)
                } else if let d = vm.detail {
                    identityCard(d)
                    if d.faltasPorMateria.isEmpty {
                        EmptyState(
                            icon: AppIcons.doc,
                            title: "Sem matérias matriculadas",
                            subtitle: "Matricule este aluno em matérias para acompanhar faltas."
                        )
                    } else {
                        SectionHeader(title: "Faltas por matéria",
                                      subtitle: "Toque para abonar")
                        VStack(spacing: AppDimens.spacingMD) {
                            ForEach(d.faltasPorMateria) { item in
                                Button {
                                    ausenciasMateria = item
                                } label: {
                                    FaltasMateriaCard(item: item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } else if let err = vm.errorMessage {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.danger)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .background(AppColors.background)
        .navigationTitle(vm.detail?.nome ?? "Aluno")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
        .sheet(item: $ausenciasMateria) { mat in
            NavigationStack {
                AusenciasView(alunoId: vm.alunoId,
                              materiaId: mat.materiaId,
                              materiaNome: mat.materiaNome)
            }
        }
    }

    private func identityCard(_ d: AlunoDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingLG) {
            HStack(alignment: .top, spacing: AppDimens.spacingMD) {
                Avatar(initials: initials(d.nome), size: 56)
                VStack(alignment: .leading, spacing: 4) {
                    Text(d.nome)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    if let ra = d.ra {
                        Text("RA \(ra)")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    if let email = d.email, !email.isEmpty {
                        Text(email)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.textTertiary)
                    }
                }
                Spacer()
            }

            if let label = d.turmaLabel, !label.isEmpty {
                HStack(spacing: AppDimens.spacingMD) {
                    metaRow(label: "Turma", value: label)
                    Divider().frame(height: 28)
                    metaRow(label: "Em risco", value: "\(d.materiasEmRisco)",
                            accent: d.materiasEmRisco > 0 ? AppColors.warning : AppColors.textPrimary)
                    Divider().frame(height: 28)
                    metaRow(label: "Reprovadas", value: "\(d.materiasReprovadas)",
                            accent: d.materiasReprovadas > 0 ? AppColors.danger : AppColors.textPrimary)
                }
            }
        }
        .padding(AppDimens.spacingXL)
        .frame(maxWidth: .infinity, alignment: .leading)
        .minimalCard(corner: 16)
    }

    private func metaRow(label: String, value: String, accent: Color = AppColors.textPrimary) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func initials(_ s: String) -> String {
        let parts = s.split(separator: " ", maxSplits: 1)
        let f = parts.first?.first.map(String.init) ?? ""
        let l = parts.count > 1 ? parts[1].first.map(String.init) ?? "" : ""
        return "\(f)\(l)".uppercased()
    }
}

private struct FaltasMateriaCard: View {
    let item: FaltasPorMateriaDTO

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            HStack(alignment: .center, spacing: AppDimens.spacingMD) {
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
                Spacer()
                Image(systemName: AppIcons.chevronRight)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textTertiary)
            }
            FaltasProgressBar(faltas: item.faltas, limite: item.limite, status: item.status)
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }
}

// MARK: - Ausências (lista granular para abono)

struct AusenciasView: View {
    @StateObject private var vm: AusenciasViewModel
    @Environment(\.dismiss) private var dismiss

    init(alunoId: Int64, materiaId: Int64, materiaNome: String) {
        _vm = StateObject(wrappedValue: AusenciasViewModel(
            alunoId: alunoId, materiaId: materiaId, materiaNome: materiaNome
        ))
    }

    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd MMM yyyy · HH:mm"
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppDimens.spacingXL) {
                Text("Selecione as faltas a abonar")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)

                if vm.isLoading && vm.ausencias.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppDimens.spacingXXL)
                } else if vm.ausencias.isEmpty {
                    EmptyState(icon: AppIcons.checkCircle,
                               title: "Sem faltas nesta matéria")
                } else {
                    VStack(spacing: AppDimens.spacingMD) {
                        ForEach(vm.ausencias) { a in
                            Button {
                                if !a.abonado { vm.toggle(a.presencaId) }
                            } label: {
                                ausenciaRow(a)
                            }
                            .buttonStyle(.plain)
                            .disabled(a.abonado)
                        }
                    }
                }

                if !vm.selecionadas.isEmpty {
                    motivoField
                    confirmButton
                }

                if let n = vm.lastAbonadas {
                    successCard(n)
                }
                if let err = vm.errorMessage {
                    Text(err)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.danger)
                }
            }
            .padding(.horizontal, AppDimens.spacingXXL)
            .padding(.top, AppDimens.spacingLG)
            .padding(.bottom, AppDimens.spacing4XL)
        }
        .background(AppColors.background)
        .navigationTitle(vm.materiaNome)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Fechar") { dismiss() }
            }
        }
        .task { await vm.load() }
    }

    private func ausenciaRow(_ a: AusenciaDTO) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(a.abonado ? AppColors.success
                                  : (vm.selecionadas.contains(a.presencaId) ? AppColors.primary : AppColors.hairline),
                                  lineWidth: 1.2)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(a.abonado ? AppColors.success.opacity(0.12)
                                  : (vm.selecionadas.contains(a.presencaId) ? AppColors.primary.opacity(0.12)
                                     : Color.clear))
                    )
                    .frame(width: 22, height: 22)
                if a.abonado {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.success)
                } else if vm.selecionadas.contains(a.presencaId) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate(a.data))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(a.abonado ? AppColors.textTertiary : AppColors.textPrimary)
                if let sala = a.sala, !sala.isEmpty {
                    Text(sala)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textSecondary)
                }
                if a.abonado {
                    Text("Abonado\(a.motivoAbono != nil ? " · \(a.motivoAbono!)" : "")")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColors.success)
                }
            }
            Spacer()
        }
        .padding(AppDimens.spacingLG)
        .minimalCard()
    }

    private var motivoField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Motivo do abono")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            TextField("Ex: atestado médico", text: $vm.motivo, axis: .vertical)
                .lineLimit(2...4)
                .padding(AppDimens.spacingMD)
                .glassCard(corner: 12)
        }
    }

    private var confirmButton: some View {
        PrimaryActionButton(
            title: "Abonar \(vm.selecionadas.count) falta\(vm.selecionadas.count == 1 ? "" : "s")",
            isLoading: vm.isSubmitting,
            disabled: !vm.canConfirm
        ) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            Task { await vm.abonar() }
        }
    }

    private func successCard(_ n: Int) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.success)
            Text("\(n) falta\(n == 1 ? "" : "s") abonada\(n == 1 ? "" : "s")")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
        .padding(AppDimens.spacingLG)
        .background(AppColors.success.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formattedDate(_ iso: String?) -> String {
        guard let iso else { return "—" }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = parser.date(from: iso + "Z") ?? parseLocal(iso) {
            return formatter.string(from: date)
        }
        return iso
    }

    private func parseLocal(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        return f.date(from: s)
    }
}
