//
//  LoginView.swift
//  QRollCall
//
//  Login em duas etapas (email → senha) com BrandMark animado e haptics
//  tácteis em todas as interações importantes.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthSession

    enum Step { case email, password }
    enum FieldFocus { case email, password }

    @State private var step: Step = .email
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hapticTrigger: Int = 0
    @State private var hapticError: Int = 0
    @State private var hapticSuccess: Int = 0
    @State private var successOverlay = false
    @State private var successFirstName = ""

    @FocusState private var focused: FieldFocus?

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                topBar

                Spacer().frame(height: 56)

                BrandMark(size: 56, isLoading: isLoading)

                Spacer().frame(height: 28)

                titleBlock

                Spacer().frame(height: 48)

                inputArea

                Spacer()

                bottomBlock
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .onAppear {
            // foca o campo certo ao abrir
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                focused = step == .email ? .email : .password
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)
        .sensoryFeedback(.error, trigger: hapticError)
        .sensoryFeedback(.success, trigger: hapticSuccess)
        .overlay {
            if successOverlay {
                LoginSuccessOverlay(userFirstName: successFirstName)
                    .transition(.opacity)
                    .zIndex(20)
            }
        }
    }

    // MARK: - Background

    /// Gradiente sutil azul → background. Cor mais saturada no topo, dissolvendo
    /// no meio da tela. Funciona em light e dark mode (no dark fica azul → preto).
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppColors.primary.opacity(0.20),
                AppColors.primary.opacity(0.06),
                AppColors.background
            ],
            startPoint: .top,
            endPoint: .center
        )
        .ignoresSafeArea()
        .overlay(AppColors.background.opacity(0.0))
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            if step == .password {
                Button {
                    goBackToEmail()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
            Spacer()
        }
        .frame(height: 32)
        .animation(.spring(duration: 0.35), value: step)
    }

    // MARK: - Title block

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .id("title-\(step)")
                .transition(.opacity.combined(with: .offset(y: 6)))

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .id("subtitle-\(step)")
                .transition(.opacity)
        }
        .animation(.spring(duration: 0.4), value: step)
    }

    private var title: String {
        switch step {
        case .email:    return "Bem-vindo ao QRollCall"
        case .password: return "Bem-vindo de volta"
        }
    }

    private var subtitle: String {
        switch step {
        case .email:    return "Entre com seu e-mail institucional"
        case .password: return "Insira sua senha para continuar"
        }
    }

    // MARK: - Inputs

    @ViewBuilder
    private var inputArea: some View {
        VStack(spacing: 12) {
            emailField
                .opacity(step == .password ? 0.55 : 1)
                .disabled(step == .password || isLoading)
                .animation(.spring(duration: 0.35), value: step)

            if step == .password {
                passwordField
                    .transition(.opacity.combined(with: .offset(y: 8)))
            }
        }
        .animation(.spring(duration: 0.4), value: step)
    }

    private var emailField: some View {
        HStack(spacing: 10) {
            TextField("E-mail institucional", text: $email)
                .focused($focused, equals: .email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .font(.system(size: 17))
                .submitLabel(.next)
                .onSubmit {
                    if canContinue { handleTap() }
                }
            if !email.isEmpty && step == .email {
                Button {
                    email = ""
                    hapticTrigger &+= 1
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .overlay {
            Capsule()
                .strokeBorder(AppColors.hairline, lineWidth: 1)
        }
    }

    private var passwordField: some View {
        HStack(spacing: 10) {
            Group {
                if showPassword {
                    TextField("Senha", text: $password)
                } else {
                    SecureField("Senha", text: $password)
                }
            }
            .focused($focused, equals: .password)
            .font(.system(size: 17))
            .submitLabel(.go)
            .onSubmit {
                if canContinue { handleTap() }
            }

            Button {
                showPassword.toggle()
                hapticTrigger &+= 1
            } label: {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .overlay {
            Capsule()
                .strokeBorder(AppColors.hairline, lineWidth: 1)
        }
    }

    // MARK: - Bottom

    private var bottomBlock: some View {
        VStack(spacing: 18) {
            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.danger)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .offset(y: 4)))
            }

            if step == .password {
                Button {
                    hapticTrigger &+= 1
                    // placeholder: futuro fluxo de recuperação
                } label: {
                    Text("Esqueceu a senha?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }

            continueButton
        }
        .animation(.spring(duration: 0.35), value: step)
        .animation(.spring(duration: 0.35), value: errorMessage)
    }

    private var continueButton: some View {
        Button {
            hapticTrigger &+= 1
            handleTap()
        } label: {
            ZStack {
                if isLoading {
                    BrandMark(size: 22, isLoading: true)
                } else {
                    Text(buttonLabel)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(canContinue ? Color.white : AppColors.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                Capsule(style: .continuous)
                    .fill(canContinue ? AppColors.primary : AppColors.surfaceMuted)
            )
            .overlay {
                if !canContinue {
                    Capsule(style: .continuous)
                        .strokeBorder(AppColors.hairline, lineWidth: 1)
                }
            }
            .shadow(
                color: canContinue ? AppColors.primary.opacity(0.28) : .clear,
                radius: 16, y: 6
            )
        }
        .buttonStyle(.plain)
        .disabled(!canContinue || isLoading)
        .animation(.spring(duration: 0.25), value: canContinue)
    }

    private var buttonLabel: String {
        step == .email ? "Continuar" : "Entrar"
    }

    private var canContinue: Bool {
        switch step {
        case .email:
            return Self.isValidEmail(email)
        case .password:
            return password.count >= 4
        }
    }

    /// Regex pragmático: algo@algo.algo, sem espaços, sem múltiplos @.
    /// Não tenta cobrir todos os RFC 5321 — só evita "@" solto liberar o botão.
    private static let emailRegex = #"^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$"#

    static func isValidEmail(_ raw: String) -> Bool {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return false }
        return s.range(of: emailRegex, options: [.regularExpression, .caseInsensitive]) != nil
    }

    // MARK: - Actions

    private func handleTap() {
        errorMessage = nil
        switch step {
        case .email:
            withAnimation(.spring(duration: 0.4)) {
                step = .password
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                focused = .password
            }
        case .password:
            Task { await performLogin() }
        }
    }

    private func goBackToEmail() {
        hapticTrigger &+= 1
        withAnimation(.spring(duration: 0.35)) {
            step = .email
        }
        password = ""
        errorMessage = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            focused = .email
        }
    }

    private func performLogin() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await AuthService.login(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            // Mostra overlay de sucesso (haptic success vem de dentro do overlay)
            successFirstName = response.firstName ?? ""
            withAnimation(.easeInOut(duration: 0.3)) {
                successOverlay = true
            }
            // Mantém ~1.2s pro user sentir o feedback
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            auth.apply(response)
        } catch let APIError.server(_, message) {
            hapticError &+= 1
            errorMessage = friendly(message) ?? "E-mail ou senha inválidos."
        } catch APIError.unauthorized {
            hapticError &+= 1
            errorMessage = "E-mail ou senha inválidos."
        } catch APIError.transport {
            hapticError &+= 1
            errorMessage = "Não foi possível conectar ao servidor."
        } catch {
            hapticError &+= 1
            errorMessage = "Erro ao entrar. Tente novamente."
        }
    }

    private func friendly(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        return raw.count > 200 ? String(raw.prefix(200)) : raw
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthSession.shared)
}
