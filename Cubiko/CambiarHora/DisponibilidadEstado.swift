//
//  DisponibilidadEstado.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import Foundation

enum DisponibilidadEstado: Equatable {
    case libre
    case conflicto
    case invalido(String)
    case validando
}
