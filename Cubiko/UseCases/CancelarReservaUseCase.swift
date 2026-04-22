//
//  CancelarReservaUseCase.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/22/26.
//


import Foundation

final class CancelarReservaUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reservaId: Int) async -> ReservaAccionEstado {
        do {
            try await repository.cancelarReserva(reservaId: reservaId)
            return .exito
            
        } catch let error as URLError {
            // Error de conexión a internet o de red
            return .error("Error de conexión: \(error.localizedDescription)")
            
        } catch {
            // Error devuelto por tu backend (ej. 403, 404, 500)
            return .error(error.localizedDescription)
        }
    }
}