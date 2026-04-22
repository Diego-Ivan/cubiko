//
//  ValidarCambioHoraUseCase.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import Foundation

final class ValidarCambioHoraUseCase {

    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reservaActiva: Reserva, nuevaEntrada: Date, nuevaSalida: Date) -> DisponibilidadEstado {
        guard nuevaSalida > nuevaEntrada else {
            return .invalido("La hora de salida debe ser después de la entrada")
        }
        guard nuevaEntrada > Date() else {
            return .invalido("La hora de entrada debe ser en el futuro")
        }

        let otrasReservas = repository.obtenerReservas().filter {
            $0.id != reservaActiva.id &&
            $0.cubiculo.id == reservaActiva.cubiculo.id
        }

        let hayConflicto = otrasReservas.contains { r in
            r.inicio < nuevaSalida && r.fin > nuevaEntrada
        }

        return hayConflicto ? .conflicto : .libre
    }
}
