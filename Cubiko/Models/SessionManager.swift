//
//  SessionManager.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI
import Combine

@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var profile: UserProfile?
    
    // Al inicializar, intentamos cargar la sesión guardada
    init() {
        loadSessionFromPersistence()
    }

    func login(with profile: UserProfile) {
        self.profile = profile
        persistSession(profile)
    }

    func logout() {
        self.profile = nil
        UserDefaults.standard.removeObject(forKey: "current_user_profile")
        KeychainManager.shared.deleteAllTokens()
        AuthManager.shared.logout()
    }
    
    func updateProfile(_ profile: UserProfile) {
        self.profile = profile
        self.persistSession(profile)
    }

   private func persistSession(_ profile: UserProfile) {
        // 1. Guardar info no sensible en UserDefaults
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "current_user_profile")
        }
        
        // 2. IMPORTANTE: Los tokens van al Keychain
        _ = KeychainManager.shared.saveAccessToken(profile.accessToken)
        if let refreshToken = profile.refreshToken {
            _ = KeychainManager.shared.saveRefreshToken(refreshToken)
        }
    }
    
    private func loadSessionFromPersistence() {
        if let savedData = UserDefaults.standard.data(forKey: "current_user_profile"),
           let savedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            
            // Verificamos que el token exista en el Keychain por seguridad
            if KeychainManager.shared.getAccessToken() != nil {
                self.profile = savedProfile
            } else {
                logout()
            }
        }
    }
}
