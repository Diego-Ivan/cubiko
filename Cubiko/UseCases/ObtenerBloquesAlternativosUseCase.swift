//
//  ObtenerBloquesAlternativosUseCase.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation

final class ObtenerBloquesAlternativosUseCase {

    private let buscarDisponibles: BuscarCubiculosDisponiblesUseCase

    init(buscarDisponibles: BuscarCubiculosDisponiblesUseCase) {
        self.buscarDisponibles = buscarDisponibles
    }

    // Cambiado a async
    func execute(inicio: Date, fin: Date, capacidad: Int) async -> [BloqueHorario] {
        let duracion = fin.timeIntervalSince(inicio)
        // Desplazamientos: -2h, -1h, +1h, +2h, +3h
        let offsets: [TimeInterval] = [-7200, -3600, 3600, 7200, 10800]
        
        var bloquesValidos: [BloqueHorario] = []

        // Iteramos sobre cada offset. Podríamos hacerlo en paralelo con un TaskGroup,
        // pero secuencialmente con un for-await es más seguro para no saturar el backend con peticiones.
        for offset in offsets {
            let nuevoInicio = inicio.addingTimeInterval(offset)
            let nuevoFin = nuevoInicio.addingTimeInterval(duracion)
            
            do {
                // Hacemos la llamada real asíncrona
                let disponibles = try await buscarDisponibles.execute(inicio: nuevoInicio, fin: nuevoFin, capacidad: capacidad)
                
                // Si hay salas disponibles en este nuevo horario, lo agregamos a las opciones
                if !disponibles.isEmpty {
                    let bloque = BloqueHorario(
                        horaInicio: nuevoInicio,
                        horaFin: nuevoFin
                        // cubiculosDisponibles: disponibles.count
                    )
                    bloquesValidos.append(bloque)
                }
            } catch {
                // Si falla la petición para un horario específico, simplemente lo ignoramos
                print("Error buscando alternativas en offset \(offset): \(error)")
                continue
            }
        }
        
        return bloquesValidos.sorted { $0.horaInicio < $1.horaInicio }
    }
}
