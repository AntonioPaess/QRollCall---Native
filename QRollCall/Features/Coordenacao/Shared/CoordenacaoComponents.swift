//
//  CoordenacaoComponents.swift
//  QRollCall
//
//  Componentes compartilhados. Design: minimalista, hairlines em vez de sombras,
//  cor reservada para status/CTA, hierarquia por peso tipográfico.
//

import SwiftUI

// MARK: - Status Badge

struct StatusBadge: View {
    let status: StatusFrequencia
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text(label)
                .font(.system(size: compact ? 11 : 12, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 4 : 5)
        .background(AppColors.surfaceMuted, in: Capsule())
        .overlay {
            Capsule().strokeBorder(AppColors.hairline, lineWidth: 0.5)
        }
    }

    private var color: Color {
        switch status {
        case .ok:        return AppColors.success
        case .alerta:    return AppColors.warning
        case .emRisco:   return AppColors.warning
        case .reprovado: return AppColors.danger
        }
    }

    private var label: String {
        switch status {
        case .ok:        return AppStrings.statusOk
        case .alerta:    return AppStrings.statusAlerta
        case .emRisco:   return AppStrings.statusEmRisco
        case .reprovado: return AppStrings.statusReprovado
        }
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppDimens.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
                .contentTransition(.numericText())
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
        .padding(AppDimens.spacingLG)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(AppColors.hairline, lineWidth: 0.5)
        }
    }
}

// MARK: - Faltas progress bar (3/15)

struct FaltasProgressBar: View {
    let faltas: Int
    let limite: Int
    let status: StatusFrequencia

    private var fraction: Double {
        guard limite > 0 else { return 0 }
        return min(1.0, Double(faltas) / Double(limite))
    }

    private var color: Color {
        switch status {
        case .ok:        return AppColors.success
        case .alerta:    return AppColors.warning
        case .emRisco:   return AppColors.warning
        case .reprovado: return AppColors.danger
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(faltas)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .contentTransition(.numericText())
                Text("/")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppColors.textTertiary)
                Text("\(limite)")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                StatusBadge(status: status, compact: true)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.surfaceMuted)
                        .frame(height: 4)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * fraction, height: 4)
                        .animation(.spring(duration: 0.45), value: fraction)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailing: AnyView? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            Spacer()
            if let trailing { trailing }
        }
    }
}

// MARK: - Empty State

struct EmptyState: View {
    let icon: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: AppDimens.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(AppColors.textTertiary)
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppDimens.spacingXXL)
    }
}

// MARK: - Premium Header

/// Header padrão das Homes — saudação + título. Sem avatar/ação à direita:
/// avatar é assunto do Perfil, não da Home.
struct PremiumHeader: View {
    let greeting: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .textCase(.uppercase)
                .tracking(0.5)
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Avatar

/// Avatar mínimo: círculo com tonalidade primary + iniciais.
/// NÃO é usado em headers de Home — só em rows de lista (busca, professores,
/// alunos) onde ajuda a distinguir nomes, e no header do Perfil.
struct Avatar: View {
    let initials: String
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(AppColors.primary.opacity(0.12))
            .frame(width: size, height: size)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(AppColors.primaryStrong)
            }
    }
}

// MARK: - Profile Header (padrão Aluno / Professor / Coordenação)

/// Header de perfil unificado:  Nome → chip de role → linhas de info
/// com ícones. Mesmas proporções e tracking em todas as roles.
struct ProfileHeader: View {
    let initials: String
    let fullName: String
    let roleLabel: String
    /// Lista de linhas (ícone SF Symbol + texto). Linhas com texto vazio são ignoradas.
    let infoLines: [InfoLine]

    struct InfoLine: Hashable {
        let icon: String
        let text: String
    }

    var body: some View {
        // Espaçamentos explícitos para um ritmo visual apertado e consistente.
        VStack(spacing: 0) {
            Avatar(initials: initials, size: 80)
                .padding(.bottom, 14)

            Text(fullName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            RoleChip(label: roleLabel)

            let visible = infoLines.filter { !$0.text.isEmpty }
            if !visible.isEmpty {
                VStack(spacing: 4) {
                    ForEach(visible, id: \.self) { line in
                        ProfileInfoLine(icon: line.icon, text: line.text)
                    }
                }
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

private struct RoleChip: View {
    let label: String
    var body: some View {
        Text(label.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(AppColors.primaryStrong)
            .tracking(0.8)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(AppColors.surfaceMuted, in: Capsule())
            .overlay { Capsule().strokeBorder(AppColors.hairline, lineWidth: 0.5) }
    }
}

private struct ProfileInfoLine: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 16, alignment: .center)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

// MARK: - Card / surface helpers

extension View {
    /// Card translúcido com Liquid Glass (iOS 26). Para elementos que flutuam sobre conteúdo.
    @ViewBuilder
    func glassCard(corner: CGFloat = 14) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular,
                             in: RoundedRectangle(cornerRadius: corner, style: .continuous))
        } else {
            self.background(.regularMaterial,
                            in: RoundedRectangle(cornerRadius: corner, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .strokeBorder(AppColors.hairline, lineWidth: 0.5)
                }
        }
    }

    /// Alias retro-compat. Tudo que usava {@code minimalCard} agora ganha Liquid Glass.
    func minimalCard(corner: CGFloat = 14) -> some View {
        glassCard(corner: corner)
    }
}

// MARK: - Botões padronizados

/// CTA primário com Liquid Glass prominent (preenche com a cor brand).
struct PrimaryActionButton: View {
    let title: String
    var isLoading: Bool = false
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white).controlSize(.small)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.glassProminent)
        .tint(AppColors.primary)
        .disabled(disabled || isLoading)
    }
}

/// CTA secundário com Liquid Glass translúcido.
struct SecondaryActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.glass)
        .tint(AppColors.primary)
    }
}
