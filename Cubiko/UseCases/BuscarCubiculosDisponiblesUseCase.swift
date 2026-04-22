//
//  BuscarCubiculosDisponiblesUseCase.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation

import Foundation

final class BuscarCubiculosDisponiblesUseCase {

    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    // Ahora es async throws y acepta la capacidad como parámetro opcional
    func execute(inicio: Date, fin: Date, capacidad: Int? = nil) async throws -> [SalaDisponible] {
        // En Clean Architecture, el backend ahora se encarga de la lógica pesada
        // de calcular qué se traslapa y qué no.
        // El Use Case simplemente pide los datos al repositorio de forma asíncrona.
        return try await repository.obtenerDisponibles(inicio: inicio, fin: fin, capacidad: capacidad)
    }
}
