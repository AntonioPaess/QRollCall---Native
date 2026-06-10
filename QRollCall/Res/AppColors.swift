//
//  AppColors.swift
//  QRollCall
//
//  Palette minimalista, single-brand. Princípios:
//  - Uma única cor de marca (azul sério). Sem gradientes decorativos.
//  - Hierarquia construída com peso tipográfico e tons neutros, não com cor.
//  - Cor reservada para CTA, estado ativo e semântica (status). Resto é neutro.
//

import SwiftUI

enum AppColors {

    // MARK: - Brand (único)

    /// Cor de marca — azul sério, sóbrio. Usada exclusivamente para CTA,
    /// estado ativo e elementos focais. Evite usar em áreas extensas.
    static let primary = Color(red: 0.13, green: 0.44, blue: 0.90)

    /// Cor de marca para texto sobre fundos pálidos (mais legível em wcag).
    static let primaryStrong = Color(red: 0.09, green: 0.34, blue: 0.78)

    // MARK: - Surfaces (neutras, adapta light/dark)

    /// Fundo principal da tela. Cinza muito sutil em light, quase preto em dark.
    static let background = Color(.systemGroupedBackground)

    /// Fundo de cards e elementos elevados.
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    /// Superfície intermediária para destaque interno (ex: chip selecionado).
    static let surfaceMuted = Color(.tertiarySystemGroupedBackground)

    /// Hairline para separadores e bordas finas. Substitui sombras.
    static let hairline = Color(.separator).opacity(0.55)

    // MARK: - Text

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Status (semânticos)

    static let success = Color(red: 0.20, green: 0.65, blue: 0.40)
    static let warning = Color(red: 0.90, green: 0.65, blue: 0.10)
    static let danger  = Color(red: 0.85, green: 0.25, blue: 0.25)

    // MARK: - Aliases legados (manter compatibilidade incremental)
    /// @deprecated use {@link primary}
    static let primaryLight = primary.opacity(0.18)
    /// @deprecated use {@link primary}
    static let purple = primary
    /// @deprecated use {@link success}
    static let green = success
    /// @deprecated use {@link danger}
    static let error = danger

    // Gradientes legados — mantidos como cor sólida (single color)
    /// @deprecated não use gradiente decorativo. Substituído por `primary` sólido.
    static let headerGradient = [primary, primary]
    static let splashGradientTop = primary
    static let splashGradientBottom = primary

    /// @deprecated — não usar em produção
    static let darkGradientTop = Color(.systemBackground)
    static let darkGradientBottom = Color(.systemBackground)

    // MARK: - Helpers

    static func primaryOpacity(_ opacity: Double) -> Color {
        primary.opacity(opacity)
    }
}
