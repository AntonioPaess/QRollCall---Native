//
//  QRollCallApp.swift
//  QRollCall
//

import SwiftUI

@main
struct QRollCallApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var auth = AuthSession.shared

    /// Splash inicial — sai após ~1.6s no SplashView.onAppear.
    @State private var splashActive = true

    var body: some Scene {
        WindowGroup {
            ZStack {
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

                if splashActive {
                    SplashView(isActive: $splashActive)
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
        }
    }
}
