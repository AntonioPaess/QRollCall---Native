import Foundation
import LocalAuthentication

@MainActor
enum FaceIDService {
    enum Result {
        case success
        case failed(String)
        case unavailable(String)
    }

    static func authenticate(reason: String = "Confirme sua presença") async -> Result {
        let context = LAContext()
        context.localizedFallbackTitle = ""

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .unavailable(error?.localizedDescription ?? "Biometria indisponível")
        }

        do {
            let ok = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                                     localizedReason: reason)
            return ok ? .success : .failed("Não foi possível validar.")
        } catch let err as LAError {
            return .failed(err.localizedDescription)
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
