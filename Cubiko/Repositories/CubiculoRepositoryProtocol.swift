//
//  CubiculoRepositoryProtocol.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation

protocol CubiculoRepositoryProtocol {
    func obtenerDisponibles(inicio: Date, fin: Date, capacidad: Int?) async throws -> [SalaDisponible]
    
    func reprogramarReserva(
        reservaId: Int,
        salaNumero: Int,
        salaUbicacion: String,
        nuevaEntrada: Date,
        nuevaSalida: Date,
        capacidad: Int?
    ) async throws
    
    func cancelarReserva(reservaId: Int) async throws

    func obtenerQrAcceso(reservaId: Int) async throws -> String
    
    func extenderReserva(reserva: Reserva, nuevaFin: Date) async throws
    
    func crearReserva(
            salaNumero: Int,
            salaUbicacion: String,
            inicio: Date,
            fin: Date,
            capacidad: Int?
        ) async throws -> Int // Devuelve el ID de la nueva reserva

}

enum ReprogramacionEstado {
    case exito
    case conflicto(String) // Cuando el backend dice que no se puede (ej. sala ocupada)
    case errorDeRed(String) // Cuando falla el internet
    
}

enum ReservaAccionEstado {
    case exito
    case error(String)
}

enum CrearReservaEstado {
    case exito(reservaId: Int)
    case error(String)
}
