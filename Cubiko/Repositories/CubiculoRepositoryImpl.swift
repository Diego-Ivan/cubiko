//
//  CubiculoRepositoryImpl.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//
import Foundation

final class CubiculoRepositoryImpl: CubiculoRepositoryProtocol {

    func obtenerTodos() -> [Cubiculo] {
        [
            Cubiculo(id: 1, nombre: "Sala #1", tipo: "Individual"),
            Cubiculo(id: 2, nombre: "Sala #2", tipo: "Individual"),
            Cubiculo(id: 3, nombre: "Sala #3", tipo: "Individual"),
            Cubiculo(id: 4, nombre: "Sala #4", tipo: "Dual"),
            Cubiculo(id: 5, nombre: "Sala #5", tipo: "Grupal"),
        ]
    }

    func obtenerReservas() -> [Reserva] {
        let cubiculos = obtenerTodos()
        let cal = Calendar.current
        func hora(_ h: Int) -> Date {
            cal.date(bySettingHour: h, minute: 0, second: 0, of: Date())!
        }
        return [
            Reserva(id: UUID(), cubiculo: cubiculos[0], inicio: hora(8), fin: hora(10)),
            Reserva(id: UUID(), cubiculo: cubiculos[1], inicio: hora(8), fin: hora(10)),
            Reserva(id: UUID(), cubiculo: cubiculos[2], inicio: hora(8), fin: hora(10)),
            Reserva(id: UUID(), cubiculo: cubiculos[3], inicio: hora(8), fin: hora(10)),
            Reserva(id: UUID(), cubiculo: cubiculos[4], inicio: hora(8), fin: hora(10)),
        ]
    }
}
