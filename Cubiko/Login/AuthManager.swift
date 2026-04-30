//
//  AuthManager.swift
//  Cubiko
//

import Foundation
import Combine

/// Helper ligero para que RealRoomRepository pueda forzar un logout
/// cuando el refresh token falla, sin acceder al entorno SwiftUI.
/// SessionManager es la fuente de verdad para la sesión de UI.
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated: Bool = false

    private init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        isAuthenticated = KeychainManager.shared.getAccessToken() != nil
    }

    /// Limpia los tokens del Keychain. La sesión de UI debe limpiarse desde SessionManager.
    func logout() {
        KeychainManager.shared.deleteAllTokens()
        DispatchQueue.main.async {
            self.isAuthenticated = false
        }
    }
}
