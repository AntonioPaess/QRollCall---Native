//
//  ProfessorProfileMockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import Foundation

struct ProfessorProfileMockData {
    static let professor = ProfessorProfileData(
        firstName: "Maria",
        lastName: "Santos",
        email: "maria.santos@universidade.edu.br",
        phone: "(11) 91234-5678",
        department: "Ciência da Computação",
        classesGiven: 48,
        averagePresence: 87,
        activeClasses: 4
    )
}

struct ProfessorProfileData {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let department: String
    let classesGiven: Int
    let averagePresence: Int
    let activeClasses: Int

    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)"
    }
    var fullName: String { "\(firstName) \(lastName)" }
}
