//
//  ProfileMockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import Foundation

// MARK: - Models

struct UserProfile {
    let firstName: String
    let lastName: String
    let matricula: String
    let email: String
    let phone: String
    let course: String
    let semester: String
    let facialUpdateDate: String

    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }

    var fullName: String { "\(firstName) \(lastName)" }
    var courseInfo: String { "\(course) - \(semester)" }
}

struct ProfileStats {
    let presenceRate: Int
    let confirmedClasses: Int
    let absences: Int
    let consecutiveDays: Int
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

// MARK: - Mock Data

struct ProfileMockData {
    static let user = UserProfile(
        firstName: "João",
        lastName: "Silva",
        matricula: "2024001234",
        email: "joao.silva@universidade.edu.br",
        phone: "(11) 98765-4321",
        course: "Ciência da Computação",
        semester: "3º Semestre",
        facialUpdateDate: "15 Jan 2025"
    )

    static let stats = ProfileStats(
        presenceRate: 92,
        confirmedClasses: 124,
        absences: 8,
        consecutiveDays: 12
    )

    static let settingsItems: [SettingsItem] = [
        SettingsItem(icon: "bell", title: "Notificações"),
        SettingsItem(icon: "shield", title: "Privacidade e LGPD"),
        SettingsItem(icon: "questionmark.circle", title: "Ajuda e Suporte")
    ]
}
