//
//  AceptarInvitacionConQrUseCase.swift
//  Cubiko
//
//  Created by Antigravity on 4/29/26.
//

import Foundation

final class AceptarInvitacionConQrUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reservaId: Int) async -> ReservaAccionEstado {
        do {
            try await repository.aceptarInvitacionConQr(reservaId: reservaId)
            return .exito
            
        } catch let error as URLError {
            return .error("Error de conexión: \(error.localizedDescription)")
            
        } catch {
            return .error(error.localizedDescription)
        }
    }
}
