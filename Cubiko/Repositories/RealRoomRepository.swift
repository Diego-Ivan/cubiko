//
//  RealRoomRepository.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//
import SwiftUI


final class RealRoomRepository: CubiculoRepositoryProtocol {
    
    let baseURL: URL
    let token: String
    
    init(baseURL: URL, token: String) {
        self.baseURL = baseURL
        self.token = token
    }
    

    func obtenerDisponibles(inicio: Date, fin: Date, capacidad: Int?) async throws -> [SalaDisponible] {
        // Construir URL con query params
        var components = URLComponents(url: baseURL.appendingPathComponent("/api/rooms/available"), resolvingAgainstBaseURL: false)!
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
            URLQueryItem(name: "horaFin", value: horaFormatter.string(from: fin))
        ]
        if let capacidad { queryItems.append(URLQueryItem(name: "capacidad", value: String(capacidad))) }
        components.queryItems = queryItems

        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if !token.isEmpty {
            // Nota: el requerimiento indica "Bearer: {token_jwt}"; comúnmente se usa "Bearer {token}" sin dos puntos.
            // Se corrigió para que coincida con el backend.
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        switch http.statusCode {
        case 200:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let decoded = try decoder.decode(AvailableRoomsResponse.self, from: data)
            // Mapear DTO a modelo de dominio `Cubiculo`
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
            // Podríamos lanzar un error específico
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
        
        // 1. Construir la URL (Asegúrate de usar tu baseURL si la tienes configurada en la clase)
        guard let url = URL(string: "http://localhost:3001/api/reservas/\(reservaId)/reschedule") else {
            throw URLError(.badURL)
        }
        
        // 2. Configurar los formateadores para coincidir con YYYY-MM-DD y HH:MM
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "es_MX_POSIX")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "es_MX_POSIX")
        
        // 3. Estructura privada para codificar el Body fácilmente a JSON
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
        
        // 4. Preparar la Request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Obtener el token de donde lo guardes (UserDefaults o propiedad de clase)
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            // Nota: La documentación dice "Bearer: {token}", pero usualmente es "Bearer {token}".
            // Lo dejo como Bearer normal, si el backend falla por falta de ":", agrégalo aquí.
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONEncoder().encode(body)
        
        // 5. Ejecutar la petición
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        // 6. Manejo de Respuestas
        if httpResponse.statusCode == 200 {
            // Éxito. No necesitamos devolver nada porque la función es void.
            return
        } else {
            // Si cae en 400, 401, 403 o 500, intentamos leer el "message" que mandó el backend
            struct BackendErrorResponse: Decodable {
                let success: Bool?
                let message: String?
            }
            
            let backendMessage = (try? JSONDecoder().decode(BackendErrorResponse.self, from: data))?.message
            let finalMessage = backendMessage ?? "Error inesperado. Código: \(httpResponse.statusCode)"
            
            // Lanzamos un error estándar de Swift usando el mensaje real del backend
            // (Ej: "Solo los estudiantes pueden reprogramar reservas" o "Conflicto de horario")
            throw NSError(
                domain: "ReprogramarReserva",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: finalMessage]
            )
        }
    }
    
    
    // MARK: - Cancelar Reserva
    func cancelarReserva(reservaId: Int) async throws {
        // Usamos el endpoint exacto y el método PATCH
        guard let url = URL(string: "http://localhost:3001/api/reservas/\(reservaId)/cancel") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            // Nota: tu doc dice "Bearer: {token_jwt}", aseguré de poner los dos puntos si el backend es estricto
            request.setValue("Bearer: \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
        // Para extender, simplemente llamamos a la función de reprogramar que ya habíamos hecho,
        // manteniendo la sala y la hora de inicio intactas, pero mandando la nueva hora de fin.
        try await reprogramarReserva(
            reservaId: reserva.id,
            salaNumero: reserva.salaNumero,
            salaUbicacion: reserva.salaUbicacion,
            nuevaEntrada: reserva.fechaInicio, // Se mantiene igual
            nuevaSalida: nuevaFin,             // <--- Esta es la que cambia
            capacidad: reserva.numPersonas
        )
    }
    
    
    func crearReserva(salaNumero: Int, salaUbicacion: String, inicio: Date, fin: Date, capacidad: Int?) async throws -> Int {
            // 1. URL de tu endpoint de creación
            guard let url = URL(string: "http://localhost:3001/api/reservas") else {
                throw URLError(.badURL)
            }
            
            // 2. Formateadores para coincidir con tu backend (YYYY-MM-DD y HH:mm)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "es_MX_POSIX")
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            timeFormatter.locale = Locale(identifier: "es_MX_POSIX")
            
            // 3. Estructura para codificar el Body
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
            
            // 4. Configurar la Petición POST
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = UserDefaults.standard.string(forKey: "access_token") {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            request.httpBody = try JSONEncoder().encode(body)
            
            // 5. Ejecutar la llamada
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            // 6. Manejo de la Respuesta
            if httpResponse.statusCode == 201 { // 201 Created según tu backend
                struct BackendSuccessResponse: Decodable {
                    struct DataObj: Decodable { let reservaId: Int }
                    let data: DataObj
                }
                let successData = try JSONDecoder().decode(BackendSuccessResponse.self, from: data)
                return successData.data.reservaId
                
            } else {
                // Manejamos los errores (Ej: "La sala ya está reservada en el rango seleccionado")
                struct BackendErrorResponse: Decodable { let message: String? }
                let backendMessage = (try? JSONDecoder().decode(BackendErrorResponse.self, from: data))?.message
                throw NSError(domain: "CrearReserva", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: backendMessage ?? "Error desconocido"])
            }
        }
    
}
