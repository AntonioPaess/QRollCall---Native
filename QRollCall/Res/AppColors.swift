//
//  AppColors.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

enum AppColors {

    // MARK: - Brand

    static let primary = Color(red: 0.38, green: 0.47, blue: 0.95)
    static let primaryLight = Color(red: 0.55, green: 0.50, blue: 0.95)
    static let purple = Color(red: 0.58, green: 0.40, blue: 0.90)
    static let green = Color(red: 0.30, green: 0.75, blue: 0.45)

    // MARK: - Gradient

    static let splashGradientTop = Color(red: 0.35, green: 0.55, blue: 1.0)
    static let splashGradientBottom = Color(red: 0.55, green: 0.75, blue: 1.0)

    static let headerGradient = [primary, primaryLight]

    static let darkGradientTop = Color(red: 0.12, green: 0.14, blue: 0.18)
    static let darkGradientBottom = Color(red: 0.18, green: 0.22, blue: 0.28)

    // MARK: - Semantic (adapta light/dark automaticamente)

    /// Fundo principal da tela
    static let background = Color(.systemGroupedBackground)

    /// Fundo dos cards
    static let cardBackground = Color(.secondarySystemGroupedBackground)

    /// Texto principal (preto em light, branco em dark)
    static let textPrimary = Color(.label)

    /// Texto secundário
    static let textSecondary = Color(.secondaryLabel)

    /// Texto terciário
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - Status

    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange

    // MARK: - Helpers

    static func primaryOpacity(_ opacity: Double) -> Color {
        primary.opacity(opacity)
    }
}
