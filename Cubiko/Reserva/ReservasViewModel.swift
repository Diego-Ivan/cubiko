//
//  ReservasViewModel.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

@Observable
class ReservasViewModel {
    var reservas: [Reserva] = []
    var isLoading = false
    var error: String?

    func fetchReservas() {
        // access_token is stored in UserDefaults under the key "access_token"
        guard let token = UserDefaults.standard.string(forKey: "access_token") else {
            self.error = "No se encontró el token de acceso. Por favor inicie sesión de nuevo."
            return
        }
        guard let url = URL(string: "http://localhost:3001/api/reservas/mis-reservas") else {
            self.error = "URL inválida."
            return
        }
        isLoading = true
        error = nil
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let decoded = try JSONDecoder().decode(ReservasResponse.self, from: data)
                    await MainActor.run {
                        self.reservas = decoded.data
                        self.isLoading = false
                    }
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    await MainActor.run {
                        self.error = "No autorizado. Inicie sesión de nuevo."
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.error = "Error inesperado al obtener las reservas."
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = "Error de red: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
