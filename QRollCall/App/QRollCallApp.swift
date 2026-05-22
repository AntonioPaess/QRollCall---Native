//
//  QRollCallApp.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

@main
struct QRollCallApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userRole") private var userRole = UserRole.student.rawValue

    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if !isLoggedIn {
                LoginView()
            } else if userRole == UserRole.professor.rawValue {
                ProfessorTabView()
            } else {
                ContentView()
            }
        }
    }
}
