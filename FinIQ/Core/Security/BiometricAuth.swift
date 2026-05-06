import Foundation
import LocalAuthentication

final class BiometricAuth {
    static let shared = BiometricAuth()
    private init() {}

    enum BiometricType {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .none
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    var isBiometricAvailable: Bool {
        biometricType != .none
    }

    func authenticate() async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw BiometricError.from(laError: error)
            }
            throw BiometricError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access your financial data"
            )
            return success
        } catch let error as LAError {
            throw BiometricError.from(laError: error)
        } catch {
            throw BiometricError.unknown
        }
    }
}

enum BiometricError: Error, LocalizedError {
    case notAvailable
    case notEnrolled
    case lockout
    case userCancel
    case systemCancel
    case passcodeNotSet
    case authenticationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .notEnrolled:
            return "No biometric data enrolled. Please set up Face ID or Touch ID in Settings"
        case .lockout:
            return "Biometric authentication is locked. Please use your passcode"
        case .userCancel:
            return "Authentication was cancelled"
        case .systemCancel:
            return "Authentication was cancelled by the system"
        case .passcodeNotSet:
            return "Please set up a passcode on your device"
        case .authenticationFailed:
            return "Authentication failed. Please try again"
        case .unknown:
            return "An unknown error occurred"
        }
    }

    static func from(laError: NSError) -> BiometricError {
        guard laError.domain == LAError.errorDomain else { return .unknown }

        switch LAError.Code(rawValue: laError.code) {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        case .userCancel:
            return .userCancel
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .authenticationFailed:
            return .authenticationFailed
        default:
            return .unknown
        }
    }

    static func from(laError: LAError) -> BiometricError {
        switch laError.code {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .lockout
        case .userCancel:
            return .userCancel
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .authenticationFailed:
            return .authenticationFailed
        default:
            return .unknown
        }
    }
}