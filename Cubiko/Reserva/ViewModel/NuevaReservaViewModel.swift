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
    
    private let crearReservaUseCase: CrearReservaUseCase
    private let buscarDisponiblesUseCase: BuscarCubiculosDisponiblesUseCase
    
    init(repository: CubiculoRepositoryProtocol = RealRoomRepository()) {
        self.crearReservaUseCase = CrearReservaUseCase(repository: repository)
        self.buscarDisponiblesUseCase = BuscarCubiculosDisponiblesUseCase(repository: repository)
    }

    private(set) var disponibilidad: [TipoCubiculo: Int] = [
        .individual: 0,
        .dual: 0,
        .grupal: 0
    ]
    
    var puedeContinuar: Bool {
        tipoSeleccionado != nil
    }
    
    func seleccionar(_ tipo: TipoCubiculo) {
        tipoSeleccionado = tipo
    }
    
    func fetchDisponibilidadActual() {
        Task {
            do {
                let inicio = Date()
                let fin = inicio.addingTimeInterval(3600) // 1 hora
                let salas = try await buscarDisponiblesUseCase.execute(inicio: inicio, fin: fin, capacidad: nil)
                
                var nuevaDisponibilidad: [TipoCubiculo: Int] = [.individual: 0, .dual: 0, .grupal: 0]
                
                for sala in salas {
                    if sala.maxPersonas == 1 {
                        nuevaDisponibilidad[.individual, default: 0] += 1
                    } else if sala.maxPersonas == 2 {
                        nuevaDisponibilidad[.dual, default: 0] += 1
                    } else {
                        nuevaDisponibilidad[.grupal, default: 0] += 1
                    }
                }
                
                await MainActor.run {
                    self.disponibilidad = nuevaDisponibilidad
                }
            } catch {
                print("Error fetching disponibilidad: \(error)")
            }
        }
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
