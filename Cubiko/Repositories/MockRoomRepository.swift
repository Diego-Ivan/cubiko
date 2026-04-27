import Foundation

final class MockRoomRepository: CubiculoRepositoryProtocol {
    
    var shouldFail = false
    var mockSalas: [SalaDisponible] = [
        SalaDisponible(numero: 1, ubicacion: "Planta Baja", maxPersonas: 4, minPersonas: 1),
        SalaDisponible(numero: 2, ubicacion: "Planta Alta", maxPersonas: 6, minPersonas: 2)
    ]
    var mockReservaId = 999
    
    func obtenerDisponibles(inicio: Date, fin: Date, capacidad: Int) async throws -> [SalaDisponible] {
        if shouldFail {
            throw URLError(.badServerResponse)
        }
        // Simular un pequeño retraso de red
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockSalas
    }
    
    func reprogramarReserva(reservaId: Int, salaNumero: Int, salaUbicacion: String, nuevaEntrada: Date, nuevaSalida: Date, capacidad: Int?) async throws {
        if shouldFail {
            throw NSError(domain: "MockError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Conflicto de horario (Mock)"])
        }
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func cancelarReserva(reservaId: Int) async throws {
        if shouldFail {
            throw URLError(.badServerResponse)
        }
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func extenderReserva(reserva: Reserva, nuevaFin: Date) async throws {
        if shouldFail {
            throw URLError(.badServerResponse)
        }
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func crearReserva(salaNumero: Int, salaUbicacion: String, inicio: Date, fin: Date, capacidad: Int?) async throws -> Int {
        if shouldFail {
            throw NSError(domain: "MockError", code: 400, userInfo: [NSLocalizedDescriptionKey: "La sala ya está ocupada (Mock)"])
        }
        try await Task.sleep(nanoseconds: 500_000_000)
        return mockReservaId
    }
}
