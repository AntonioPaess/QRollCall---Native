//
//  AuthMockData.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import Foundation

// MARK: - Models

enum UserRole: String {
    case student = "Aluno"
    case professor = "Professor"
}

// MARK: - Mock Auth

struct AuthMockData {
    static func login(email: String, password: String, role: UserRole) -> Bool {
        return !email.isEmpty && !password.isEmpty
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let dismissAttendanceFlow = Notification.Name("dismissAttendanceFlow")
}
