////
////  CubiculoRepositoryImpl.swift
////  Cubiko
////
////  Created by Rafael on 13/04/26.
////
//import Foundation
//
//final class CubiculoRepositoryImpl: CubiculoRepositoryProtocol {
//
//    func obtenerTodos() -> [Cubiculo] {
//        [
//            Cubiculo(id: 1, nombre: "Sala #1", tipo: "Individual"),
//            Cubiculo(id: 2, nombre: "Sala #2", tipo: "Individual"),
//            Cubiculo(id: 3, nombre: "Sala #3", tipo: "Individual"),
//            Cubiculo(id: 4, nombre: "Sala #4", tipo: "Dual"),
//            Cubiculo(id: 5, nombre: "Sala #5", tipo: "Grupal"),
//        ]
//    }
//
//    func obtenerReservas() -> [Reserva] {
//        let hoy = Date()
//        
//        // Helper para crear los DateComponents requeridos por el nuevo modelo
//        func componentesHora(_ h: Int) -> DateComponents {
//            DateComponents(hour: h, minute: 0, second: 0)
//        }
//        
//        // Adaptamos el mock a la nueva firma requerida en Reserva.swift
//        return [
//            Reserva(id: 1, estudianteId: 1, salaUbicacion: "Biblioteca", salaNumero: 1, fechaInicio: hoy, fechaFin: hoy, horaInicio: componentesHora(8), horaFin: componentesHora(10), numPersonas: 1),
//            Reserva(id: 2, estudianteId: 1, salaUbicacion: "Biblioteca", salaNumero: 2, fechaInicio: hoy, fechaFin: hoy, horaInicio: componentesHora(8), horaFin: componentesHora(10), numPersonas: 1),
//            Reserva(id: 3, estudianteId: 1, salaUbicacion: "Biblioteca", salaNumero: 3, fechaInicio: hoy, fechaFin: hoy, horaInicio: componentesHora(8), horaFin: componentesHora(10), numPersonas: 1),
//            Reserva(id: 4, estudianteId: 1, salaUbicacion: "Biblioteca", salaNumero: 4, fechaInicio: hoy, fechaFin: hoy, horaInicio: componentesHora(8), horaFin: componentesHora(10), numPersonas: 2),
//            Reserva(id: 5, estudianteId: 1, salaUbicacion: "Biblioteca", salaNumero: 5, fechaInicio: hoy, fechaFin: hoy, horaInicio: componentesHora(8), horaFin: componentesHora(10), numPersonas: 4),
//        ]
//    }
//}
