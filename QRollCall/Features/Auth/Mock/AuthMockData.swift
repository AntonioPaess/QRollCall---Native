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
    case coordenacao = "Coordenacao"
}

// MARK: - Notifications

extension Notification.Name {
    static let dismissAttendanceFlow = Notification.Name("dismissAttendanceFlow")
}
