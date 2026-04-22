//
//  BuscadorViewModel.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation
import Combine

// MARK: - Models used by the ViewModel

//struct BloqueHorario: Identifiable, Hashable {
//    let id = UUID()
//    let horaInicio: Date
//    let horaFin: Date
//}

struct SalaDisponible {
    let numero: Int
    let ubicacion: String
    let maxPersonas: Int
    let minPersonas: Int
}
                            
                            
private struct AvailableRoomsResponse: Decodable {
    struct RoomDTO: Decodable {
        let numero: Int
        let ubicacion: String
        let maxPersonas: Int
        // La especificación repite maxPersonas, asumimos que el segundo campo es minPersonas
        let minPersonas: Int?

        enum CodingKeys: String, CodingKey {
            case numero
            case ubicacion
            case maxPersonas
            case minPersonas
        }
    }

    let data: [RoomDTO]
}

enum BuscadorEstado {
    case inicial
    case disponible([SalaDisponible])
    case sinDisponibilidad([BloqueHorario])
}

@MainActor
final class BuscadorViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var fechaSeleccionada: Date = Date()
    @Published var horaEntrada: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @Published var horaSalida: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @Published var capacidadMinima: Int? = nil

    // Token JWT para Authorization: "Bearer: {token_jwt}"
    @Published var token: String = ""

    // Base URL del backend (ajústala según tu entorno)
    var baseURL: URL = URL(string: "http://localhost:3001")!

    // MARK: - Outputs
    @Published private(set) var estado: BuscadorEstado = .inicial

    // MARK: - Init
    init() {}

    // MARK: - Actions
    func buscar() {
        Task { await buscarAsync() }
    }

    func seleccionarBloque(_ bloque: BloqueHorario) {
        horaEntrada = bloque.horaInicio
        horaSalida  = bloque.horaFin
        buscar()
    }

    // MARK: - Networking
    private func buscarAsync() async {
        let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin    = combinando(fecha: fechaSeleccionada, con: horaSalida)

        do {
            let disponibles = try await fetchDisponibles(inicio: inicio, fin: fin, capacidad: capacidadMinima)
            if !disponibles.isEmpty {
                self.estado = .disponible(disponibles)
            } else {
                // No hay disponibles; ofrecemos bloques alternativos simples (p. ej., mover 30 min)
                let alternativas = generarAlternativas(baseInicio: inicio, baseFin: fin)
                self.estado = .sinDisponibilidad(alternativas)
            }
        } catch {
            // En caso de error, también podríamos reflejarlo en el estado; por ahora sugerimos alternativas
            let alternativas = generarAlternativas(baseInicio: inicio, baseFin: fin)
            self.estado = .sinDisponibilidad(alternativas)
        }
    }

    private func fetchDisponibles(inicio: Date, fin: Date, capacidad: Int?) async throws -> [SalaDisponible] {
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

    // MARK: - Helpers
    private func combinando(fecha: Date, con hora: Date) -> Date {
        let cal = Calendar.current
        let hc  = cal.dateComponents([.hour, .minute], from: hora)
        return cal.date(bySettingHour: hc.hour ?? 0,
                        minute: hc.minute ?? 0,
                        second: 0,
                        of: fecha) ?? fecha
    }

    private func generarAlternativas(baseInicio: Date, baseFin: Date) -> [BloqueHorario] {
        // Estrategia simple: proponer +/- 30 y 60 minutos
        let cal = Calendar.current
        let offsets: [TimeInterval] = [-3600, -1800, 1800, 3600]
        return offsets.compactMap { offset in
            let nuevoInicio = baseInicio.addingTimeInterval(offset)
            let dur = baseFin.timeIntervalSince(baseInicio)
            let nuevoFin = nuevoInicio.addingTimeInterval(dur)
            return BloqueHorario(horaInicio: nuevoInicio, horaFin: nuevoFin)
        }
    }
}

// MARK: - Factory
extension BuscadorViewModel {
    static func makeDefault() -> BuscadorViewModel {
        let vm = BuscadorViewModel()
        // Ajusta baseURL y token según tu entorno
        // vm.baseURL = URL(string: "https://tu-backend")!
        // vm.token = "token_jwt"
        return vm
    }
}
