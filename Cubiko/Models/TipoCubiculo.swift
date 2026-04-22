//
//  TipoCubiculo.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

enum TipoCubiculo: String, CaseIterable {
    case individual = "Individual"
    case dual       = "Dual"
    case grupal     = "Grupal"

    var icono: String {
        switch self {
        case .individual: return "person.fill"
        case .dual:       return "person.2.fill"
        case .grupal:     return "person.3.fill"
        }
    }

    var descripcion: String {
        switch self {
        case .individual: return "Concentración total para ti solo."
        case .dual:       return "Colaboración en pareja."
        case .grupal:     return "Espacio amplio para grandes ideas."
        }
    }
}
