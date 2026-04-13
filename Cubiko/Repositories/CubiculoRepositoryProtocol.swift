//
//  CubiculoRepositoryProtocol.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation

protocol CubiculoRepositoryProtocol {
    func obtenerTodos() -> [Cubiculo]
    func obtenerReservas() -> [Reserva]
}
