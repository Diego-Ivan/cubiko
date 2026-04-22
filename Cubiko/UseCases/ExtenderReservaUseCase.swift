//
//  ExtenderReservaUseCase.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/22/26.
//


import Foundation

final class ExtenderReservaUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    // Ahora pedimos la reserva completa
    func execute(reservaActiva: Reserva, nuevaFin: Date) async -> ReservaAccionEstado {
        // Validación local
        guard nuevaFin > Date() else {
            return .error("La nueva hora de fin debe ser en el futuro.")
        }
        
        do {
            // Le pasamos todo al repositorio
            try await repository.extenderReserva(reserva: reservaActiva, nuevaFin: nuevaFin)
            return .exito
            
        } catch let error as URLError {
            return .error("Error de red: \(error.localizedDescription)")
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
