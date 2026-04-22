//
//  UserProfile.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//


import Foundation

struct UserProfile: Codable, Equatable {
//    let estudiante: Estudiante
    var accessToken: String
    var refreshToken: String?
    var expiresAt: Date?

    // Acceso rápido a datos comunes
//    var id: Int { estudiante.id }
//    var nombre: String { estudiante.nombre }

    var authorizationHeaderValue: String? {
        // Estándar: "Bearer <token>"
        accessToken.isEmpty ? nil : "Bearer \(accessToken)"
    }

    var isTokenValid: Bool {
        guard let exp = expiresAt else { return !accessToken.isEmpty }
        // Se recomienda restar unos 60 segundos para margen de maniobra
        return Date().addingTimeInterval(60) < exp && !accessToken.isEmpty
    }
}
