//
//  LoginView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthSession

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            logoSection

            Spacer().frame(height: AppDimens.spacing4XL)

            formSection

            if let errorMessage {
                Text(errorMessage)
                    .font(.system(size: AppDimens.fontCaption, weight: .medium))
                    .foregroundColor(AppColors.error)
                    .padding(.top, AppDimens.spacingMD)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            loginButton

            Spacer().frame(height: AppDimens.spacing4XL)
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .background(AppColors.background)
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: AppDimens.spacingLG) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.primary.opacity(0.12))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: AppIcons.qrCode)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppColors.primary)
                }

            VStack(spacing: 6) {
                Text(AppStrings.loginTitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(AppColors.textSecondary)
                Text(AppStrings.appName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: AppDimens.spacingMD) {
            inputRow(icon: AppIcons.emailIcon) {
                TextField(AppStrings.emailPlaceholder, text: $email)
                    .font(.system(size: 16))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }

            inputRow(icon: AppIcons.lockIcon) {
                SecureField(AppStrings.passwordPlaceholder, text: $password)
                    .font(.system(size: 16))
            }
        }
    }

    private func inputRow<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: AppDimens.spacingMD) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textTertiary)
                .frame(width: 20)
            content()
        }
        .padding(.horizontal, AppDimens.spacingLG)
        .padding(.vertical, 14)
        .glassCard(corner: 12)
    }

    // MARK: - Login Button

    private var loginButton: some View {
        PrimaryActionButton(
            title: AppStrings.loginButton,
            isLoading: isLoading,
            disabled: !canSubmit
        ) {
            Task { await performLogin() }
        }
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty
        && !password.isEmpty
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
            auth.apply(response)
        } catch let APIError.server(_, message) {
            errorMessage = friendly(message) ?? "Email ou senha inválidos."
        } catch APIError.unauthorized {
            errorMessage = "Email ou senha inválidos."
        } catch APIError.transport {
            errorMessage = "Não foi possível conectar ao servidor."
        } catch {
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
