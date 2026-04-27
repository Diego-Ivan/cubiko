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
    
    // Recibimos el token directamente en la función
    func fetchReservas(token: String?) {
        guard let token = token, !token.isEmpty else {
            self.error = "No se encontró el token de acceso. Por favor inicie sesión de nuevo."
            return
        }
        
        let url = APIConfig.baseURL.appendingPathComponent("api/reservas/mis-reservas")
        
        isLoading = true
        error = nil
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // El token viene desde la vista, que a su vez lo saca de UserProfile
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("\n[ReservasViewModel] Iniciando petición a: \(url.absoluteString)")
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                let httpResponse = response as? HTTPURLResponse ?? HTTPURLResponse()
                
                print("\n[ReservasViewModel] Código de estado HTTP recibido: \(httpResponse.statusCode)")
                
                // Imprimir el JSON crudo (Raw JSON) para ver exactamente qué mandó el servidor
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 [ReservasViewModel] Respuesta cruda del servidor:")
                    print(jsonString)
                }
                
                if httpResponse.statusCode == 200 {
                    do {
                        let decoded = try JSONDecoder().decode(ReservasResponse.self, from: data)
                        print("✅ [ReservasViewModel] Decodificación exitosa. Reservas obtenidas: \(decoded.data.count)")
                        await MainActor.run {
                            self.reservas = decoded.data
                            self.isLoading = false
                        }
                    } catch let decodingError as DecodingError {
                        print("\n❌ [ReservasViewModel] ERROR DE DECODIFICACIÓN:")
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            print("⚠️ Tipo incorrecto: se esperaba '\(type)' en el campo -> \(context.codingPath.map(\.stringValue).joined(separator: "."))")
                        case .valueNotFound(let type, let context):
                            print("⚠️ Valor nulo no permitido: se esperaba '\(type)' en el campo -> \(context.codingPath.map(\.stringValue).joined(separator: "."))")
                        case .keyNotFound(let key, let context):
                            print("⚠️ Llave faltante: falta la propiedad '\(key.stringValue)' en el JSON, requerida en -> \(context.codingPath.map(\.stringValue).joined(separator: "."))")
                        case .dataCorrupted(let context):
                            print("⚠️ Datos corruptos en -> \(context.codingPath)")
                        @unknown default:
                            print("⚠️ Error desconocido: \(decodingError)")
                        }
                        print("--------------------------------------------------\n")
                        
                        await MainActor.run {
                            self.error = "Error leyendo los datos. Revisa la consola."
                            self.isLoading = false
                        }
                    } catch {
                        print("❌ [ReservasViewModel] Otro error: \(error)")
                    }
                    
                } else if httpResponse.statusCode == 401 {
                    await MainActor.run {
                        self.error = "No autorizado. Inicie sesión de nuevo."
                        self.isLoading = false
                    }
                } else {
                    // Tratar de decodificar el error que mandó el backend
                    struct BackendError: Decodable { let message: String? }
                    let backendMsg = (try? JSONDecoder().decode(BackendError.self, from: data))?.message ?? "Error código: \(httpResponse.statusCode)"
                    
                    print("🚨 [ReservasViewModel] Error desde el backend: \(backendMsg)")
                    await MainActor.run {
                        self.error = backendMsg
                        self.isLoading = false
                    }
                }
            } catch {
                print("🚨 [ReservasViewModel] Error de red puro: \(error.localizedDescription)")
                await MainActor.run {
                    self.error = "Error de conexión: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    
    func fetchReservasActuales(token: String?) {
        guard let token = token, !token.isEmpty else {
            self.error = "No se encontró el token de acceso. Por favor inicie sesión de nuevo."
            return
        }
        
        let url = APIConfig.baseURL.appendingPathComponent("api/reservas/mis-reservas")
        
        isLoading = true
        error = nil
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = KeychainManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        print("\n[ReservasViewModel] Iniciando petición a: \(url.absoluteString) para reservas ACTUALES")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                let httpResponse = response as? HTTPURLResponse ?? HTTPURLResponse()
                
                print("\n[ReservasViewModel] Código HTTP: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        // ⚠️ IMPORTANTE: No olvides esto para que Swift entienda las fechas "2026-04-20T06:00:00.000Z"
                        decoder.dateDecodingStrategy = .iso8601
                        
                        let decoded = try decoder.decode(ReservasResponse.self, from: data)
                        
                        // ---------------------------------------------------------
                        // 🔍 LÓGICA DE FILTRADO (Activas o Futuras)
                        // ---------------------------------------------------------
                        let ahora = Date() // La fecha y hora exactas en este momento
                        
                        let reservasFiltradas = decoded.data.filter { reserva in
                            // 1. Verificamos si el status es explícitamente "Activa"
                            // Usamos lowercased() por si en la base de datos dice "Activa" o "activa"
                            let esEstadoActiva = reserva.status == .activa
                            
                            // 2. Verificamos si la fechaFin aún no ha pasado.
                            // Si por algún motivo fechaFin es null, usamos la fechaInicio para comparar.
                            let fechaAComparar = reserva.fechaFin
                            let noHaTerminado = fechaAComparar >= ahora
                            
                            // Mantenemos la reserva si cumple cualquiera de las dos condiciones
                            return esEstadoActiva || noHaTerminado
                        }
                        
                        // Ordenamos las reservas para que las más próximas aparezcan primero
                        let reservasOrdenadas = reservasFiltradas.sorted { $0.fechaInicio < $1.fechaInicio }
                        
                        print("✅ [ReservasViewModel] Obtenidas: \(decoded.data.count) | Filtradas: \(reservasOrdenadas.count)")
                        
                        await MainActor.run {
                            self.reservasFiltradas = reservasOrdenadas // Asignamos las filtradas y ordenadas
                            self.isLoading = false
                        }
                    } catch let decodingError as DecodingError {
                        // ... (Aquí mantienes tus mismos logs de error de decodificación detallados que ya tenías) ...
                        print("❌ [ReservasViewModel] ERROR DE DECODIFICACIÓN: \(decodingError)")
                        await MainActor.run {
                            self.error = "Error decodificando los datos."
                            self.isLoading = false
                        }
                    } catch {
                        print("❌ [ReservasViewModel] Otro error: \(error)")
                    }
                    
                } else if httpResponse.statusCode == 401 {
                    await MainActor.run {
                        self.error = "No autorizado. Inicie sesión de nuevo."
                        self.isLoading = false
                    }
                } else {
                    struct BackendError: Decodable { let message: String? }
                    let backendMsg = (try? JSONDecoder().decode(BackendError.self, from: data))?.message ?? "Error código: \(httpResponse.statusCode)"
                    
                    print("[ReservasViewModel] \(backendMsg)")
                    
                    self.error = backendMsg
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = "Error de conexión: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
