//
//  AttendanceMockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import Foundation

// MARK: - Models

struct ActiveAttendance {
    let className: String
    let professorName: String
    let room: String
    let startTime: String
    let classType: ClassType
    let correctWords: [String]
    let allWords: [String]

    static func mock() -> ActiveAttendance {
        let correct = ["HTML", "CSS", "JavaScript", "React"]
        let distractors = ["FUTEBOL", "RECEITA", "CINEMA", "PRAIA", "MÚSICA", "VIAGEM"]
        let all = (correct + distractors).shuffled()

        return ActiveAttendance(
            className: "Programação Web",
            professorName: "Prof. Maria Santos",
            room: "Lab 101",
            startTime: "10:00",
            classType: .first,
            correctWords: correct,
            allWords: all
        )
    }
}

// MARK: - Mock Data

struct AttendanceMockData {
    static let activeAttendance = ActiveAttendance.mock()

    static var isInBluetoothRange: Bool = true

    static func toggleRange() {
        isInBluetoothRange.toggle()
    }
}
