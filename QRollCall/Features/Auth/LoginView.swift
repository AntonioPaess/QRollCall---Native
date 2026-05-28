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
    @State private var selectedRole: UserRole = .student
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

            rolePicker

            Spacer().frame(height: AppDimens.spacingXXL)

            loginButton

            Spacer().frame(height: AppDimens.spacing4XL)
        }
        .padding(.horizontal, AppDimens.spacingXXL)
        .background(AppColors.background)
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: AppDimens.spacingMD) {
            ZStack {
                RoundedRectangle(cornerRadius: AppDimens.radiusXL)
                    .fill(
                        LinearGradient(
                            colors: AppColors.headerGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 15, y: 8)

                Image(systemName: AppIcons.qrCode)
                    .font(.system(size: AppDimens.icon3XL - 10, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: AppDimens.spacingXS) {
                Text(AppStrings.loginTitle)
                    .font(.system(size: AppDimens.fontCallout, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                Text(AppStrings.appName)
                    .font(.system(size: AppDimens.fontHero, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: AppDimens.spacingLG) {
            HStack(spacing: AppDimens.spacingMD) {
                Image(systemName: AppIcons.emailIcon)
                    .font(.system(size: AppDimens.iconMD))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: AppDimens.iconXL)
                TextField(AppStrings.emailPlaceholder, text: $email)
                    .font(.system(size: AppDimens.fontCallout))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            .padding(AppDimens.spacingLG)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))

            HStack(spacing: AppDimens.spacingMD) {
                Image(systemName: AppIcons.lockIcon)
                    .font(.system(size: AppDimens.iconMD))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: AppDimens.iconXL)
                SecureField(AppStrings.passwordPlaceholder, text: $password)
                    .font(.system(size: AppDimens.fontCallout))
            }
            .padding(AppDimens.spacingLG)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
    }

    // MARK: - Role Picker

    private var rolePicker: some View {
        HStack(spacing: 0) {
            roleButton(role: .student, label: AppStrings.iAmStudent)
            roleButton(role: .professor, label: AppStrings.iAmProfessor)
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
    }

    private func roleButton(role: UserRole, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedRole = role
            }
        } label: {
            Text(label)
                .font(.system(size: AppDimens.fontSmall, weight: selectedRole == role ? .semibold : .regular))
                .foregroundColor(selectedRole == role ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppDimens.spacingMD)
                .background(selectedRole == role ? AppColors.primary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Login Button

    private var loginButton: some View {
        Button {
            Task { await performLogin() }
        } label: {
            ZStack {
                Text(AppStrings.loginButton)
                    .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                if isLoading {
                    ProgressView().tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppDimens.buttonHeight)
            .background(canSubmit ? AppColors.primary : AppColors.primaryOpacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit || isLoading)
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
                password: password,
                role: selectedRole
            )
            auth.apply(response, requestedRole: selectedRole)
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
