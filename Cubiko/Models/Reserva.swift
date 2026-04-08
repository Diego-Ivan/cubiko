//
//  Reserva.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import Foundation

struct Reserva: Identifiable {
    let id: UUID
    let cubiculo: Cubiculo
    let inicio: Date
    let fin: Date

    /// Minutos que faltan para que termine la reserva (puede ser negativo si ya terminó)
    var minutosRestantes: Double {
        fin.timeIntervalSinceNow / 60
    }

    var yaTermino: Bool {
        Date() >= fin
    }
}
