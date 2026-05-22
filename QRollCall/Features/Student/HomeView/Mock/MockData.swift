//
//  MockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import Foundation

// MARK: - Models

struct User {
    let firstName: String
    let lastName: String
    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
    var fullName: String { "\(firstName) \(lastName)" }
}

struct NextClass {
    let name: String
    let startTime: String
    let endTime: String
    let room: String
    let timeUntil: String
    let progress: Double
}

struct AttendanceStats {
    let presencePercentage: Int
    let presenceChange: String
    let totalClasses: Int
    let absences: Int
    let streakDays: Int
}

struct RecentActivity: Identifiable {
    let id = UUID()
    let className: String
    let date: String
    let time: String
    let status: AttendanceStatus
}

enum AttendanceStatus: String {
    case presente = "Presente"
    case ausente = "Ausente"
    case justificado = "Justificado"
}

// MARK: - Mock Data

struct MockData {
    static let user = User(
        firstName: "João",
        lastName: "Silva"
    )

    static let nextClass = NextClass(
        name: "Cálculo Diferencial",
        startTime: "14:00",
        endTime: "15:40",
        room: "Sala 203",
        timeUntil: "em 1h",
        progress: 0.25
    )

    static let stats = AttendanceStats(
        presencePercentage: 92,
        presenceChange: "+3% este mês",
        totalClasses: 124,
        absences: 8,
        streakDays: 12
    )

    static let recentActivities: [RecentActivity] = [
        RecentActivity(
            className: "Programação Web",
            date: "Hoje",
            time: "10:00",
            status: .presente
        ),
        RecentActivity(
            className: "Banco de Dados",
            date: "Ontem",
            time: "14:00",
            status: .presente
        ),
        RecentActivity(
            className: "Engenharia de Software",
            date: "Ontem",
            time: "10:00",
            status: .presente
        ),
        RecentActivity(
            className: "Redes de Computadores",
            date: "07/04",
            time: "08:00",
            status: .ausente
        )
    ]
}
