//
//  SessionManager.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI
import Combine

/// Fuente de verdad para la sesión del usuario.
/// - Los tokens se guardan/leen siempre desde el Keychain (KeychainManager).
/// - Solo datos no sensibles (expiresAt) se persisten en UserDefaults.
@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var profile: UserProfile?

    init() {
        loadSessionFromPersistence()
    }

    // MARK: - API pública

    /// Inicia sesión guardando los tokens en el Keychain y el perfil en UserDefaults.
    func login(accessToken: String, refreshToken: String?, expiresAt: Date? = nil) {
        _ = KeychainManager.shared.saveAccessToken(accessToken)
        if let refreshToken {
            _ = KeychainManager.shared.saveRefreshToken(refreshToken)
        }
        let perfil = UserProfile(expiresAt: expiresAt)
        self.profile = perfil
        persistProfile(perfil)
    }

    func logout() {
        profile = nil
        UserDefaults.standard.removeObject(forKey: "current_user_profile")
        KeychainManager.shared.deleteAllTokens()
    }

    func updateExpiresAt(_ date: Date?) {
        let updatedProfile = UserProfile(expiresAt: date)
        self.profile = updatedProfile
        persistProfile(updatedProfile)
    }

    // MARK: - Persistencia privada

    private func persistProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "current_user_profile")
        }
    }

    private func loadSessionFromPersistence() {
        guard
            let savedData = UserDefaults.standard.data(forKey: "current_user_profile"),
            let savedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData),
            KeychainManager.shared.getAccessToken() != nil
        else {
            UserDefaults.standard.removeObject(forKey: "current_user_profile")
            return
        }
        self.profile = savedProfile
    }
}
