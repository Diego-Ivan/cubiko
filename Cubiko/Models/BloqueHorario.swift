//
//  BloqueHorario.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation

struct BloqueHorario: Identifiable {
    let id = UUID()
    let horaInicio: Date
    let horaFin: Date
//    let cubiculosDisponibles: Int
}
