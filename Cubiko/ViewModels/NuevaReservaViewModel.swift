//
//  NuevaReservaViewModel.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI
import Observation

@Observable
class NuevaReservaViewModel {
    var tipoSeleccionado: TipoCubiculo? = nil
    var navegarASiguiente = false
    
    // Esto después lo podrías obtener de tu Repositorio
    private(set) var disponibilidad: [TipoCubiculo: Int] = [
        .individual: 10,
        .dual: 4,
        .grupal: 6
    ]
    
    var puedeContinuar: Bool {
        tipoSeleccionado != nil
    }
    
    func seleccionar(_ tipo: TipoCubiculo) {
        tipoSeleccionado = tipo
    }
}
