//
//  RealRoomRepository.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//
import SwiftUI

final class RealRoomRepository: CubiculoRepositoryProtocol {
    
    init() {}
    
    // MARK: - Autenticación y Refresh Token Helper
    private func performAuthenticatedRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var mutableRequest = request
        if let token = KeychainManager.shared.getAccessToken() {
            mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var (data, response) = try await URLSession.shared.data(for: mutableRequest)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            // Intentar refresh token
            if let newAccessToken = try await refreshToken() {
                mutableRequest.setValue("Bearer \(newAccessToken)", forHTTPHeaderField: "Authorization")
                (data, response) = try await URLSession.shared.data(for: mutableRequest)
            }
        }
        
        return (data, response)
    }
    
    private func refreshToken() async throws -> String? {
        guard let refreshToken = KeychainManager.shared.getRefreshToken() else {
            AuthManager.shared.logout()
            throw URLError(.userAuthenticationRequired)
        }
        
        let url = APIConfig.baseURL.appendingPathComponent("api/auth/refresh")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["refresh_token": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            AuthManager.shared.logout()
            throw URLError(.userAuthenticationRequired)
        }
        
        struct RefreshResponse: Decodable {
            struct TokenData: Decodable {
                let access_token: String
                let refresh_token: String?
            }
            let data: TokenData
        }
        
        if let decoded = try? JSONDecoder().decode(RefreshResponse.self, from: data) {
            _ = KeychainManager.shared.saveAccessToken(decoded.data.access_token)
            if let newRefresh = decoded.data.refresh_token {
                _ = KeychainManager.shared.saveRefreshToken(newRefresh)
            }
            return decoded.data.access_token
        } else {
            AuthManager.shared.logout()
            throw URLError(.userAuthenticationRequired)
        }
    }

    func obtenerDisponibles(inicio: Date, fin: Date, capacidad: Int) async throws -> [SalaDisponible] {
        var components = URLComponents(url: APIConfig.baseURL.appendingPathComponent("api/rooms/available"), resolvingAgainstBaseURL: false)!
        let fechaFormatter = DateFormatter()
        fechaFormatter.calendar = Calendar(identifier: .gregorian)
        fechaFormatter.locale = Locale(identifier: "es_MX_POSIX")
        fechaFormatter.dateFormat = "yyyy-MM-dd"

        let horaFormatter = DateFormatter()
        horaFormatter.calendar = Calendar(identifier: .gregorian)
        horaFormatter.locale = Locale(identifier: "es_MX_POSIX")
        horaFormatter.dateFormat = "HH:mm"

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "fecha", value: fechaFormatter.string(from: inicio)),
            URLQueryItem(name: "horaInicio", value: horaFormatter.string(from: inicio)),
            URLQueryItem(name: "horaFin", value: horaFormatter.string(from: fin)),
            URLQueryItem(name: "capacidad", value: String(capacidad))
        ]
        components.queryItems = queryItems

        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await performAuthenticatedRequest(request)
        
        print("ROOMS: \(String(data: data, encoding: .utf8) ?? "<no data>") \(response)")

        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        switch http.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let decoded = try decoder.decode(AvailableRoomsResponse.self, from: data)
            let salas: [SalaDisponible] = decoded.data.map { dto in
                SalaDisponible(
                    numero: dto.numero,
                    ubicacion: dto.ubicacion,
                    maxPersonas: dto.maxPersonas,
                    minPersonas: dto.minPersonas ?? 1
                )
            }
            return salas
        case 401:
            throw URLError(.userAuthenticationRequired)
        default:
            throw URLError(.badServerResponse)
        }
    }
    
    
    func reprogramarReserva(
            reservaId: Int,
            salaNumero: Int,
            salaUbicacion: String,
            nuevaEntrada: Date,
            nuevaSalida: Date,
            capacidad: Int?
        ) async throws {
        
        let url = APIConfig.baseURL.appendingPathComponent("api/reservas/\(reservaId)/reschedule")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "es_MX_POSIX")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "es_MX_POSIX")
        
        struct ReprogramarBody: Encodable {
            let salaNumero: Int
            let salaUbicacion: String
            let fechaInicio: String
            let horaInicio: String
            let fechaFin: String
            let horaFin: String
            let numPersonas: Int?
        }
        
        let body = ReprogramarBody(
            salaNumero: salaNumero,
            salaUbicacion: salaUbicacion,
            fechaInicio: dateFormatter.string(from: nuevaEntrada),
            horaInicio: timeFormatter.string(from: nuevaEntrada),
            fechaFin: dateFormatter.string(from: nuevaSalida),
            horaFin: timeFormatter.string(from: nuevaSalida),
            numPersonas: capacidad
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await performAuthenticatedRequest(request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode == 200 {
            return
        } else {
            struct BackendErrorResponse: Decodable {
                let success: Bool?
                let message: String?
            }
            
            let backendMessage = (try? JSONDecoder().decode(BackendErrorResponse.self, from: data))?.message
            let finalMessage = backendMessage ?? "Error inesperado. Código: \(httpResponse.statusCode)"
            
            throw NSError(
                domain: "ReprogramarReserva",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: finalMessage]
            )
        }
    }
    
    
    // MARK: - Cancelar Reserva
    func cancelarReserva(reservaId: Int) async throws {
        let url = APIConfig.baseURL.appendingPathComponent("api/reservas/\(reservaId)/cancel")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        let (data, response) = try await performAuthenticatedRequest(request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            struct BackendErrorResponse: Decodable { let message: String? }
            let backendMessage = (try? JSONDecoder().decode(BackendErrorResponse.self, from: data))?.message
            throw NSError(domain: "CancelarReserva", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: backendMessage ?? "Error al cancelar"])
        }
    }

    // MARK: - Extender Reserva (Reutiliza Reprogramar)
    func extenderReserva(reserva: Reserva, nuevaFin: Date) async throws {
        try await reprogramarReserva(
            reservaId: reserva.id,
            salaNumero: reserva.salaNumero,
            salaUbicacion: reserva.salaUbicacion,
            nuevaEntrada: reserva.fechaInicio,
            nuevaSalida: nuevaFin,
            capacidad: reserva.numPersonas
        )
    }
    
    
    func crearReserva(salaNumero: Int, salaUbicacion: String, inicio: Date, fin: Date, capacidad: Int?) async throws -> Int {
            let url = APIConfig.baseURL.appendingPathComponent("api/reservas/create")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "es_MX_POSIX")
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.locale = Locale(identifier: "es_MX_POSIX")
            
            struct CrearBody: Encodable {
                let salaNumero: Int
                let salaUbicacion: String
                let fechaInicio: String
                let horaInicio: String
                let fechaFin: String
                let horaFin: String
                let numPersonas: Int?
            }
            
            let body = CrearBody(
                salaNumero: salaNumero,
                salaUbicacion: salaUbicacion,
                fechaInicio: dateFormatter.string(from: inicio),
                horaInicio: timeFormatter.string(from: inicio),
                fechaFin: dateFormatter.string(from: fin),
                horaFin: timeFormatter.string(from: fin),
                numPersonas: capacidad
            )
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, response) = try await performAuthenticatedRequest(request)
        
            print("NUEVA RESERVA: \(String(data: data, encoding: .utf8) ?? "<no data>") \(response)")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            if httpResponse.statusCode == 201 {
                struct BackendSuccessResponse: Decodable {
                    struct DataObj: Decodable { let reservaId: Int }
                    let data: DataObj
                }
                let successData = try JSONDecoder().decode(BackendSuccessResponse.self, from: data)
                return successData.data.reservaId
                
            } else {
                struct BackendErrorResponse: Decodable { let message: String? }
                let backendMessage = (try? JSONDecoder().decode(BackendErrorResponse.self, from: data))?.message
                throw NSError(domain: "CrearReserva", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: backendMessage ?? "Error desconocido"])
            }
        }
    
}
