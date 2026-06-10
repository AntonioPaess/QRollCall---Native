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
    @StateObject private var auth = AuthSession.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if !auth.isAuthenticated {
                    LoginView()
                } else if auth.role == .coordenacao {
                    CoordenacaoTabView()
                } else if auth.role == .professor {
                    ProfessorTabView()
                } else {
                    ContentView()
                }
            }
            .environmentObject(auth)
        }
    }
}
