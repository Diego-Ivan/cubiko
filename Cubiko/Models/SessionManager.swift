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
    
    // Al inicializar, podrías intentar cargar la sesión guardada
    init() {
        // loadSessionFromPersistence()
    }

    func login(with profile: UserProfile) {
        self.profile = profile
        persistSession(profile)
    }

    func logout() {
        self.profile = nil
        // Borrar de Keychain y UserDefaults
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
        
        // 2. IMPORTANTE: Los tokens deberían ir al Keychain
        // saveToKeychain(profile.accessToken)
    }
    
    
}
