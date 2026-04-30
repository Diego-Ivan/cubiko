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
    var reservasFiltradas: [Reserva] = []
    var isLoading = false
    var error: String?
    
    /// Carga todas las reservas (uso general)
    func fetchReservas() {
        guard let token = KeychainManager.shared.getAccessToken(), !token.isEmpty else {
            self.error = "No se encontró el token de acceso. Por favor inicie sesión de nuevo."
            return
        }
        
        let url = APIConfig.baseURL.appendingPathComponent("api/reservas/mis-reservas")
        
        isLoading = true
        error = nil
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                await procesarRespuesta(data: data, response: response, esActuales: false)
            } catch {
                await manejarErrorRed(error)
            }
        }
    }
    
    /// Carga y filtra las reservas para mostrar solo las actuales/futuras
    func fetchReservasActuales() {
        guard let token = KeychainManager.shared.getAccessToken(), !token.isEmpty else {
            self.error = "No se encontró el token de acceso. Por favor inicie sesión de nuevo."
            return
        }
        
        let url = APIConfig.baseURL.appendingPathComponent("api/reservas/mis-reservas")
        
        isLoading = true
        error = nil
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                await procesarRespuesta(data: data, response: response, esActuales: true)
            } catch {
                await manejarErrorRed(error)
            }
        }
    }
    
    @MainActor
    private func procesarRespuesta(data: Data, response: URLResponse, esActuales: Bool) {
        let httpResponse = response as? HTTPURLResponse ?? HTTPURLResponse()
        
        if httpResponse.statusCode == 200 {
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(ReservasResponse.self, from: data)
                
                if esActuales {
                    let ahora = Date()
                    let filtradas = decoded.data.filter { r in
                        let esActiva = r.status == .activa || r.status == .reservada
                        let noHaTerminado = r.fechaFin >= ahora
                        return esActiva || noHaTerminado
                    }
                    self.reservasFiltradas = filtradas.sorted { $0.fechaInicio < $1.fechaInicio }
                } else {
                    self.reservas = decoded.data
                }
                self.isLoading = false
            } catch {
                self.error = "Error al procesar los datos del servidor."
                self.isLoading = false
            }
        } else if httpResponse.statusCode == 401 {
            self.error = "No autorizado. Inicie sesión de nuevo."
            self.isLoading = false
        } else {
            struct BackendError: Decodable { let message: String? }
            let msg = (try? JSONDecoder().decode(BackendError.self, from: data))?.message ?? "Error \(httpResponse.statusCode)"
            self.error = msg
            self.isLoading = false
        }
    }
    
    @MainActor
    private func manejarErrorRed(_ error: Error) {
        self.error = "Error de conexión: \(error.localizedDescription)"
        self.isLoading = false
    }
}
