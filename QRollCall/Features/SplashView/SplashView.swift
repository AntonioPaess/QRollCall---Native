//
//  SplashView.swift
//  QRollCall
//
//  Loader de abertura do app (estilo Wise): fundo primary sólido, marca QR em
//  branco com animação de wave nos data dots, haptic suave ao aparecer e
//  transição fade-out limpa ao concluir.
//

import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool

    @State private var markScale: CGFloat = 0.6
    @State private var markOpacity: Double = 0
    @State private var hapticTrigger = 0

    var body: some View {
        ZStack {
            AppColors.primary.ignoresSafeArea()

            BrandMark(size: 52, isLoading: true, style: .onColor)
                .scaleEffect(markScale)
                .opacity(markOpacity)
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.6), trigger: hapticTrigger)
        .onAppear {
            hapticTrigger &+= 1
            withAnimation(.spring(duration: 0.55, bounce: 0.28)) {
                markScale = 1.0
                markOpacity = 1.0
            }
            // ~1.6s de splash, depois fade-out suave
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    isActive = false
                }
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
