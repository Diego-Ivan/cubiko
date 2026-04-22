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
    
    private let crearReservaUseCase = CrearReservaUseCase(repository: RealRoomRepository(baseURL: URL(string: "http://localhost:3001/")!, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidGlwbyI6ImVzdHVkaWFudGUiLCJlbWFpbCI6ImF6dWFueS5taWxhY25AdWRsYXAubXgiLCJpYXQiOjE3NzY4MjMyNDcsImV4cCI6MTc3NjkwOTY0N30.hF7frRzHMEPUdd8jkAp83NAuAIBCwtuv9hX4Q25w4Bo")
    )

    
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
    

    func crearReserva(sala: SalaDisponible, inicio: Date, fin: Date) {
        // Podrías poner una variable isLoading = true aquí
        
        Task {
            let resultado = await crearReservaUseCase.execute(
                sala: sala,
                inicio: inicio,
                fin: fin,
                capacidad: tipoSeleccionado?.capacidad
            )
            
            switch resultado {
            case .exito(let id):
                print("¡Reserva \(id) creada con éxito!")
                // Aquí cerramos el Wizard y mandamos al usuario a la primera pestaña
                await MainActor.run {
                    self.navegarASiguiente = false
                    self.tipoSeleccionado = nil
                    // Si usas un TabView, aquí cambiarías la pestaña seleccionada a 0
                }
                
            case .error(let mensaje):
                print("Error creando: \(mensaje)")
                // Aquí puedes mostrar un Alert con el mensaje de error en la UI
            }
        }
    }
}
