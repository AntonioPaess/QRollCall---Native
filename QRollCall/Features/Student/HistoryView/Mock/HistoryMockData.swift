//
//  HistoryMockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import Foundation

// MARK: - Models

enum HistoryFilter: String, CaseIterable {
    case todas = "Todas"
    case presente = "Presente"
    case ausente = "Falta"
}

struct HistorySummary {
    let presences: Int
    let absences: Int
    var rate: Int {
        let total = presences + absences
        guard total > 0 else { return 0 }
        return Int(round(Double(presences) / Double(total) * 100))
    }
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let className: String
    let date: String
    let time: String
    let room: String
    let status: AttendanceStatus
}

// MARK: - Mock Data

struct HistoryMockData {
    static let summary = HistorySummary(
        presences: 6,
        absences: 2
    )

    static let entries: [HistoryEntry] = [
        HistoryEntry(
            className: "Programação Web",
            date: "Hoje",
            time: "10:00",
            room: "Lab 101",
            status: .presente
        ),
        HistoryEntry(
            className: "Banco de Dados",
            date: "Ontem",
            time: "14:00",
            room: "Sala 205",
            status: .presente
        ),
        HistoryEntry(
            className: "Engenharia de Software",
            date: "15 Mar",
            time: "08:00",
            room: "Sala 103",
            status: .ausente
        ),
        HistoryEntry(
            className: "Cálculo Diferencial",
            date: "14 Mar",
            time: "14:00",
            room: "Sala 203",
            status: .presente
        )
    ]
}
