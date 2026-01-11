// AuthService.swift
// Face ID / Touch ID authentication service

import Foundation
import LocalAuthentication
import SwiftUI

// MARK: - Biometric Type
public enum BiometricType {
    case none
    case touchID
    case faceID
}

// MARK: - Auth Service
@MainActor
public class AuthService: ObservableObject {
    @Published public var isAuthenticated = false
    @Published public var authError: String?

    private let context = LAContext()
    private let keychain = KeychainService()

    public var biometricType: BiometricType {
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .faceID // Treat Vision Pro as Face ID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    public init() {
        // Check if already authenticated this session
        if UserDefaults.standard.bool(forKey: "sessionAuthenticated") {
            // Validate session hasn't expired (24 hours)
            if let lastAuth = UserDefaults.standard.object(forKey: "lastAuthTime") as? Date {
                if Date().timeIntervalSince(lastAuth) < 86400 { // 24 hours
                    isAuthenticated = true
                }
            }
        }
    }

    // MARK: - Biometric Authentication
    public func authenticate() async {
        let context = LAContext()
        var error: NSError?

        // Check if biometrics available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            authError = error?.localizedDescription ?? "Biometrics not available"
            return
        }

        let reason = "Authenticate to access PetroWise"

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            if success {
                completeAuthentication()
            }
        } catch let error as LAError {
            switch error.code {
            case .userCancel:
                authError = "Authentication cancelled"
            case .userFallback:
                // User chose to use passcode
                authError = nil
            case .biometryNotAvailable:
                authError = "Biometrics not available"
            case .biometryNotEnrolled:
                authError = "Biometrics not enrolled"
            case .biometryLockout:
                authError = "Biometrics locked. Try again later."
            default:
                authError = error.localizedDescription
            }
        } catch {
            authError = error.localizedDescription
        }
    }

    // MARK: - Manual Authentication (Passcode)
    public func manualAuthenticate() {
        completeAuthentication()
    }

    // MARK: - Sign Out
    public func signOut() {
        isAuthenticated = false
        UserDefaults.standard.set(false, forKey: "sessionAuthenticated")
        UserDefaults.standard.removeObject(forKey: "lastAuthTime")
    }

    // MARK: - Private Helpers
    private func completeAuthentication() {
        isAuthenticated = true
        UserDefaults.standard.set(true, forKey: "sessionAuthenticated")
        UserDefaults.standard.set(Date(), forKey: "lastAuthTime")

        // Haptic feedback
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

// MARK: - Keychain Service
class KeychainService {
    private let service = "com.jrdcompanies.petrowise"

    func save(_ data: Data, for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func load(for key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func delete(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Convenience Methods
    func saveString(_ string: String, for key: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return save(data, for: key)
    }

    func loadString(for key: String) -> String? {
        guard let data = load(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
