//
//  ActivarReservaUseCase.swift
//  Cubiko
//
//  Created by Antigravity on 4/29/26.
//

import Foundation

final class ActivarReservaUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol = RealRoomRepository()) {
        self.repository = repository
    }

    func execute(reservaId: Int) async -> ReservaAccionEstado {
        do {
            try await repository.activarReserva(reservaId: reservaId)
            return .exito
            
        } catch let error as URLError {
            return .error("Error de conexión: \(error.localizedDescription)")
            
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
