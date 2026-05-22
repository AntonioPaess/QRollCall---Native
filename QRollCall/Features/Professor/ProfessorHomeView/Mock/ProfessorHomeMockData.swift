//
//  ProfessorHomeMockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import Foundation

// MARK: - Models

struct ProfessorUser {
    let firstName: String
    let lastName: String
    let department: String

    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
    var fullName: String { "\(firstName) \(lastName)" }
}

struct ProfessorClass: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let room: String
    let schedule: String
    let totalStudents: Int
    let averagePresence: Int
    let studentsAtRisk: Int
}

struct ProfessorNextClass {
    let name: String
    let startTime: String
    let endTime: String
    let room: String
    let totalStudents: Int
}

struct ProfessorStats {
    let averagePresence: Int
    let classesGiven: Int
}

struct PastAttendance: Identifiable {
    let id = UUID()
    let className: String
    let date: String
    let time: String
    let presentCount: Int
    let totalCount: Int
    let classType: ClassType

    var presencePercentage: Int {
        guard totalCount > 0 else { return 0 }
        return Int(round(Double(presentCount) / Double(totalCount) * 100))
    }
}

enum ClassType: String {
    case first = "1ª Aula"
    case second = "2ª Aula"
    case conjugated = "Conjugadas"

    var absenceCount: Int {
        switch self {
        case .first, .second: return 1
        case .conjugated: return 2
        }
    }
}

struct StudentAttendanceRecord: Identifiable {
    let id = UUID()
    let name: String
    let matricula: String
    let presencePercentage: Int
    let isPresent: Bool
    let confirmedAt: String?

    var initials: String {
        let parts = name.split(separator: " ")
        let f = parts.first?.prefix(1) ?? ""
        let l = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(f)\(l)"
    }
}

// MARK: - Mock Data

struct ProfessorHomeMockData {
    static let professor = ProfessorUser(
        firstName: "Maria",
        lastName: "Santos",
        department: "Ciência da Computação"
    )

    static let nextClass = ProfessorNextClass(
        name: "Programação Web",
        startTime: "10:00",
        endTime: "11:40",
        room: "Lab 101",
        totalStudents: 35
    )

    static let stats = ProfessorStats(
        averagePresence: 87,
        classesGiven: 48
    )

    static let classes: [ProfessorClass] = [
        ProfessorClass(
            name: "Programação Web",
            code: "CC401",
            room: "Lab 101",
            schedule: "Seg/Qua 10:00",
            totalStudents: 35,
            averagePresence: 91,
            studentsAtRisk: 2
        ),
        ProfessorClass(
            name: "Banco de Dados",
            code: "CC302",
            room: "Sala 205",
            schedule: "Ter/Qui 14:00",
            totalStudents: 28,
            averagePresence: 85,
            studentsAtRisk: 4
        ),
        ProfessorClass(
            name: "Engenharia de Software",
            code: "CC501",
            room: "Sala 103",
            schedule: "Seg/Qua 08:00",
            totalStudents: 32,
            averagePresence: 78,
            studentsAtRisk: 6
        ),
        ProfessorClass(
            name: "Cálculo Diferencial",
            code: "MT201",
            room: "Sala 203",
            schedule: "Ter/Qui 16:00",
            totalStudents: 40,
            averagePresence: 82,
            studentsAtRisk: 5
        )
    ]

    static let pastAttendances: [PastAttendance] = [
        PastAttendance(className: "Programação Web", date: "Hoje", time: "10:00", presentCount: 32, totalCount: 35, classType: .first),
        PastAttendance(className: "Banco de Dados", date: "Ontem", time: "14:00", presentCount: 25, totalCount: 28, classType: .conjugated),
        PastAttendance(className: "Engenharia de Software", date: "15 Mar", time: "08:00", presentCount: 28, totalCount: 32, classType: .second),
        PastAttendance(className: "Cálculo Diferencial", date: "14 Mar", time: "16:00", presentCount: 36, totalCount: 40, classType: .first)
    ]

    static let studentsForClass: [StudentAttendanceRecord] = [
        StudentAttendanceRecord(name: "João Silva", matricula: "2024001234", presencePercentage: 92, isPresent: true, confirmedAt: "10:02"),
        StudentAttendanceRecord(name: "Ana Oliveira", matricula: "2024001235", presencePercentage: 88, isPresent: true, confirmedAt: "10:03"),
        StudentAttendanceRecord(name: "Pedro Costa", matricula: "2024001236", presencePercentage: 95, isPresent: true, confirmedAt: "10:01"),
        StudentAttendanceRecord(name: "Mariana Lima", matricula: "2024001237", presencePercentage: 72, isPresent: false, confirmedAt: nil),
        StudentAttendanceRecord(name: "Lucas Ferreira", matricula: "2024001238", presencePercentage: 68, isPresent: false, confirmedAt: nil),
        StudentAttendanceRecord(name: "Camila Souza", matricula: "2024001239", presencePercentage: 90, isPresent: true, confirmedAt: "10:05"),
        StudentAttendanceRecord(name: "Rafael Mendes", matricula: "2024001240", presencePercentage: 85, isPresent: true, confirmedAt: "10:04"),
        StudentAttendanceRecord(name: "Beatriz Rocha", matricula: "2024001241", presencePercentage: 78, isPresent: true, confirmedAt: "10:06"),
    ]

    static let gamificationWordSets: [String: [String]] = [
        "Programação Web": ["HTML", "CSS", "JavaScript", "React", "API", "DOM", "HTTP", "REST"],
        "Banco de Dados": ["SQL", "JOIN", "INDEX", "SELECT", "INSERT", "TABLE", "KEY", "QUERY"],
        "Engenharia de Software": ["SCRUM", "SPRINT", "KANBAN", "AGILE", "DEPLOY", "GIT", "CI/CD", "TEST"],
        "Cálculo Diferencial": ["LIMITE", "DERIVADA", "INTEGRAL", "FUNÇÃO", "TAXA", "CURVA", "RETA", "MÁXIMO"]
    ]

    static let distractorWords = ["FUTEBOL", "RECEITA", "CINEMA", "PRAIA", "MÚSICA", "VIAGEM", "JOGO", "NOVELA", "PIZZA", "SÉRIE"]
}
