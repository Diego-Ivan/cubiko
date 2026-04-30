//
//  UserProfile.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import Foundation

/// Datos del perfil de usuario que se persisten en UserDefaults.
/// IMPORTANTE: los tokens (accessToken / refreshToken) se almacenan
/// exclusivamente en el Keychain mediante KeychainManager y quedan
/// excluidos de la serialización Codable para no quedar en UserDefaults.
struct UserProfile: Codable, Equatable {

    var expiresAt: Date?

    // MARK: - CodingKeys
    // Solo codificamos campos no sensibles. Los tokens se leen del Keychain en tiempo de ejecución.
    enum CodingKeys: String, CodingKey {
        case expiresAt
    }

    // MARK: - Propiedades calculadas (leen del Keychain en tiempo real)

    var accessToken: String {
        KeychainManager.shared.getAccessToken() ?? ""
    }

    var refreshToken: String? {
        KeychainManager.shared.getRefreshToken()
    }

    var authorizationHeaderValue: String? {
        accessToken.isEmpty ? nil : "Bearer \(accessToken)"
    }

    var isTokenValid: Bool {
        guard let exp = expiresAt else { return !accessToken.isEmpty }
        return Date().addingTimeInterval(60) < exp && !accessToken.isEmpty
    }
}
