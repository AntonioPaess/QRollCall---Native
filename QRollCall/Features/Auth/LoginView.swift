//
//  LoginView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userRole") private var userRole = UserRole.student.rawValue

    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .student
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            logoSection

            Spacer().frame(height: AppDimens.spacing4XL)

            formSection

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
            if AuthMockData.login(email: email, password: password, role: selectedRole) {
                userRole = selectedRole.rawValue
                isLoggedIn = true
            } else {
                showError = true
            }
        } label: {
            Text(AppStrings.loginButton)
                .font(.system(size: AppDimens.fontTitle3, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: AppDimens.buttonHeight)
                .background(AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: AppDimens.radiusMD))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
}
