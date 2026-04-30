//
//  FinalizarReservaUseCase.swift
//  Cubiko
//
//  Created by Antigravity on 4/30/26.
//

import Foundation

final class FinalizarReservaUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol = RealRoomRepository()) {
        self.repository = repository
    }

    func execute(reservaId: Int) async -> ReservaAccionEstado {
        do {
            try await repository.finalizarReserva(reservaId: reservaId)
            return .exito
            
        } catch let error as URLError {
            return .error("Error de conexión: \(error.localizedDescription)")
            
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
