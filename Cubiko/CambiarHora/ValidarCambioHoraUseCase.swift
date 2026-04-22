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

    func execute(reservaActiva: Reserva, nuevaEntrada: Date, nuevaSalida: Date) async -> DisponibilidadEstado {
        // 1. Validaciones básicas de tiempo
        guard nuevaSalida > nuevaEntrada else {
            return .invalido("La hora de salida debe ser después de la entrada.")
        }
        guard nuevaEntrada > Date() else {
            return .invalido("La hora de entrada debe ser en el futuro.")
        }

        do {
            // 2. Pedimos al backend las salas disponibles en el NUEVO horario propuesto
            let salasDisponibles = try await repository.obtenerDisponibles(
                inicio: nuevaEntrada,
                fin: nuevaSalida,
                capacidad: reservaActiva.numPersonas
            )

            // 3. Verificamos que la reserva actual tenga una sala asignada
            // (Usamos los nombres de propiedades basados en tu modelo Reserva actualizado)
//            guard let numeroActual = reservaActiva.salaNumero,
//                  let ubicacionActual = reservaActiva.salaUbicacion else {
//                return .invalido("La reserva actual no tiene una sala asignada.")
//            }
            let numeroActual = reservaActiva.salaNumero
            let ubicacionActual = reservaActiva.salaUbicacion
            
            // 4. ¿Nuestra sala actual sigue estando libre en este nuevo horario?
            let salaSigueLibre = salasDisponibles.contains { sala in
                sala.numero == numeroActual &&
                sala.ubicacion == ubicacionActual
            }

            // Si está en la lista de disponibles, no hay conflicto. Si no, alguien más ya la ocupó.
            return salaSigueLibre ? .libre : .conflicto
            
        } catch {
            // Si hay un error de red o de servidor, devolvemos un estado inválido
            return .invalido("Error de conexión al verificar disponibilidad.")
        }
    }
}
