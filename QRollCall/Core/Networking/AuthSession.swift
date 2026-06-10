import Combine
import Foundation
import SwiftUI

@MainActor
final class AuthSession: ObservableObject {
    @Published private(set) var token: String?
    @Published private(set) var role: UserRole?
    @Published private(set) var firstName: String = ""
    @Published private(set) var lastName: String = ""
    @Published private(set) var email: String = ""
    @Published private(set) var username: String = ""

    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userRole") private var storedRole = UserRole.student.rawValue

    static let shared = AuthSession()

    init() {
        self.token = KeychainStore.read(KeychainStore.Keys.token)
        self.username = KeychainStore.read(KeychainStore.Keys.username) ?? ""
        self.email = KeychainStore.read(KeychainStore.Keys.email) ?? ""
        self.firstName = KeychainStore.read(KeychainStore.Keys.firstName) ?? ""
        self.lastName = KeychainStore.read(KeychainStore.Keys.lastName) ?? ""
        if let rawRole = KeychainStore.read(KeychainStore.Keys.role),
           let parsed = UserRole(rawValue: rawRole) {
            self.role = parsed
        }
    }

    var isAuthenticated: Bool { token != nil }

    func apply(_ response: LoginResponseDTO) {
        token = response.accessToken
        firstName = response.firstName ?? splitName(response.username).0
        lastName = response.lastName ?? splitName(response.username).1
        email = response.email
        username = response.username

        let resolved: UserRole = {
            let raw = response.role.lowercased()
            if raw.contains("coord") || raw == "admin" { return .coordenacao }
            if raw.contains("prof") { return .professor }
            return .student
        }()
        role = resolved
        storedRole = resolved.rawValue
        isLoggedIn = true

        KeychainStore.save(response.accessToken, for: KeychainStore.Keys.token)
        KeychainStore.save(resolved.rawValue, for: KeychainStore.Keys.role)
        KeychainStore.save(response.username, for: KeychainStore.Keys.username)
        KeychainStore.save(response.email, for: KeychainStore.Keys.email)
        KeychainStore.save(firstName, for: KeychainStore.Keys.firstName)
        KeychainStore.save(lastName, for: KeychainStore.Keys.lastName)
    }

    func logout() {
        token = nil
        role = nil
        firstName = ""
        lastName = ""
        email = ""
        username = ""
        isLoggedIn = false
        KeychainStore.clearAll()
    }

    var initials: String {
        let f = firstName.prefix(1)
        let l = lastName.prefix(1)
        return "\(f)\(l)".uppercased()
    }

    var fullName: String {
        let combined = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return combined.isEmpty ? username : combined
    }

    private func splitName(_ name: String) -> (String, String) {
        let parts = name.trimmingCharacters(in: .whitespaces).split(separator: " ", maxSplits: 1)
        let first = parts.first.map(String.init) ?? ""
        let last = parts.count > 1 ? String(parts[1]) : ""
        return (first, last)
    }
}
