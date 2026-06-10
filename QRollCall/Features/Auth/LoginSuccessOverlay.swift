//
//  LoginSuccessOverlay.swift
//  QRollCall
//
//  Loader pós-login: mesma marca/tamanho do Splash (continuidade visual),
//  com sequência:  marca aparece → wave breve → checkmark sutil → mensagem
//  de boas-vindas com o primeiro nome do user. Haptic .success ao entrar.
//

import SwiftUI

struct LoginSuccessOverlay: View {
    var userFirstName: String = ""

    @State private var markScale: CGFloat = 0.7
    @State private var markOpacity: Double = 0
    @State private var greetingOffset: CGFloat = 12
    @State private var greetingOpacity: Double = 0
    @State private var hapticTrigger = 0
    @State private var stillLoading = true

    var body: some View {
        ZStack {
            AppColors.primary.ignoresSafeArea()

            VStack(spacing: 20) {
                BrandMark(size: 52, isLoading: stillLoading, style: .onColor)
                    .scaleEffect(markScale)
                    .opacity(markOpacity)

                VStack(spacing: 4) {
                    Text(userFirstName.isEmpty ? "Bem-vindo" : "Bem-vindo de volta,")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.78))
                        .tracking(0.2)

                    if !userFirstName.isEmpty {
                        Text(userFirstName)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .offset(y: greetingOffset)
                .opacity(greetingOpacity)
            }
        }
        .sensoryFeedback(.success, trigger: hapticTrigger)
        .onAppear {
            // 1) marca entra
            withAnimation(.spring(duration: 0.45, bounce: 0.28)) {
                markScale = 1.0
                markOpacity = 1.0
            }
            // 2) trigger haptic logo de cara
            hapticTrigger &+= 1

            // 3) após breve onda nos dots, marca para de pulsar (estado "ok")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    stillLoading = false
                }
            }

            // 4) greeting sobe sutilmente
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                withAnimation(.easeOut(duration: 0.35)) {
                    greetingOffset = 0
                    greetingOpacity = 1.0
                }
            }
        }
    }
}

#Preview {
    LoginSuccessOverlay(userFirstName: "Vinicius")
}
