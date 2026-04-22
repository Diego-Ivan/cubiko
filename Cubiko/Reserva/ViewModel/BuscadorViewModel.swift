//
//  BuscadorViewModel.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation
import Combine
internal import System


enum BuscadorEstado {
    case inicial
    case disponible([SalaDisponible])
    case sinDisponibilidad([BloqueHorario])
}

@MainActor
final class BuscadorViewModel: ObservableObject {
    @Published var fechaSeleccionada: Date = Date()
    @Published var horaEntrada: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @Published var horaSalida: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @Published var capacidadMinima: Int? = nil

    @Published private(set) var estado: BuscadorEstado = .inicial

    var onReservar: ((SalaDisponible, Date, Date) -> Void)?

    // Use Cases
    private let buscarDisponibles: BuscarCubiculosDisponiblesUseCase
//    private let obtenerAlternativos: ObtenerBloquesAlternativosUseCase

    
    init(
        buscarDisponibles: BuscarCubiculosDisponiblesUseCase,
//        obtenerAlternativos: ObtenerBloquesAlternativosUseCase,
        onReservar: ((SalaDisponible, Date, Date) -> Void)? = nil
    ) {
        self.buscarDisponibles   = buscarDisponibles
//        self.obtenerAlternativos = obtenerAlternativos
        self.onReservar = onReservar
    }

    func buscar() {
        Task {
            let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
            let fin    = combinando(fecha: fechaSeleccionada, con: horaSalida)
            
            do {
                // The ViewModel delegates the heavy lifting to the Use Case
                let disponibles = try await buscarDisponibles.execute(inicio: inicio, fin: fin, capacidad: capacidadMinima)
                
                if !disponibles.isEmpty {
                    self.estado = .disponible(disponibles)
                } else {
                    let alternativas = generarAlternativas(baseInicio: inicio, baseFin: fin)
                    self.estado = .sinDisponibilidad(alternativas)
                }
            } catch {
                let alternativas = generarAlternativas(baseInicio: inicio, baseFin: fin)
                self.estado = .sinDisponibilidad(alternativas)
            }
        }
    }
    
    func seleccionarBloque(_ bloque: BloqueHorario) {
        horaEntrada = bloque.horaInicio
        horaSalida  = bloque.horaFin
        buscar()
    }
    
    // Keep Main's selection method
    func seleccionarSala(_ sala: SalaDisponible) {
        let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin    = combinando(fecha: fechaSeleccionada, con: horaSalida)
        onReservar?(sala, inicio, fin)
    }
    
    
    // MARK: - Helpers
    private func combinando(fecha: Date, con hora: Date) -> Date {
        let cal = Calendar.current
        let hc  = cal.dateComponents([.hour, .minute], from: hora)
        return cal.date(bySettingHour: hc.hour ?? 0,
                        minute: hc.minute ?? 0,
                        second: 0,
                        of: fecha) ?? fecha
    }

    private func generarAlternativas(baseInicio: Date, baseFin: Date) -> [BloqueHorario] {
        // Estrategia simple: proponer +/- 30 y 60 minutos
        let cal = Calendar.current
        let offsets: [TimeInterval] = [-3600, -1800, 1800, 3600]
        return offsets.compactMap { offset in
            let nuevoInicio = baseInicio.addingTimeInterval(offset)
            let dur = baseFin.timeIntervalSince(baseInicio)
            let nuevoFin = nuevoInicio.addingTimeInterval(dur)
            return BloqueHorario(horaInicio: nuevoInicio, horaFin: nuevoFin)
        }
    }
    
    static func make(onReservar: ((SalaDisponible, Date, Date) -> Void)? = nil) -> BuscadorViewModel {
        let repo         = RealRoomRepository(baseURL: URL(string: "http://localhost:3001/")!, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidGlwbyI6ImVzdHVkaWFudGUiLCJlbWFpbCI6ImF6dWFueS5taWxhY25AdWRsYXAubXgiLCJpYXQiOjE3NzY4MjMyNDcsImV4cCI6MTc3NjkwOTY0N30.hF7frRzHMEPUdd8jkAp83NAuAIBCwtuv9hX4Q25w4Bo")
        let buscar       = BuscarCubiculosDisponiblesUseCase(repository: repo)
        let alternativos = ObtenerBloquesAlternativosUseCase(buscarDisponibles: buscar)
        return BuscadorViewModel(buscarDisponibles: buscar, onReservar: onReservar)
    }
}
