////
////  ObtenerBloquesAlternativosUseCase.swift
////  Cubiko
////
////  Created by Rafael on 13/04/26.
////
//
//import Foundation
//
//final class ObtenerBloquesAlternativosUseCase {
//
//    private let buscarDisponibles: BuscarCubiculosDisponiblesUseCase
//
//    init(buscarDisponibles: BuscarCubiculosDisponiblesUseCase) {
//        self.buscarDisponibles = buscarDisponibles
//    }
//
//    func execute(inicio: Date, fin: Date) -> [BloqueHorario] {
//        let duracion = fin.timeIntervalSince(inicio)
//        let offsets: [TimeInterval] = [-7200, -3600, 3600, 7200, 10800]
//
//        return offsets.compactMap { offset in
//            let nuevoInicio = inicio.addingTimeInterval(offset)
//            let nuevoFin = nuevoInicio.addingTimeInterval(duracion)
//            let disponibles = buscarDisponibles.execute(inicio: nuevoInicio, fin: nuevoFin)
//            guard !disponibles.isEmpty else { return nil }
//            return BloqueHorario(
//                horaInicio: nuevoInicio,
//                horaFin: nuevoFin,
//                cubiculosDisponibles: disponibles.count
//            )
//        }
//        .sorted { $0.horaInicio < $1.horaInicio }
//    }
//}
