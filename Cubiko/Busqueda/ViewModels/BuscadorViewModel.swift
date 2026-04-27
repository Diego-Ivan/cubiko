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
    @Published var fechaFin: Date = Date()
    @Published var horaEntrada: Date = Date().addingTimeInterval(60)
    @Published var horaSalida: Date = Date().addingTimeInterval(1860)
    @Published var capacidadMinima: Int = 1
    @Published var salaSeleccionada: SalaDisponible?

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
                    self.salaSeleccionada = disponibles.first
                    self.estado = .disponible(disponibles)
                } else {
                    self.estado = .sinDisponibilidad([])
                }
            } catch {
                self.estado = .sinDisponibilidad([])
            }
        }
    }
    
    func seleccionarBloque(_ bloque: BloqueHorario) {
        horaEntrada = bloque.horaInicio
        horaSalida  = bloque.horaFin
        buscar()
    }
    
    // Guardar selección
    func seleccionarSala(_ sala: SalaDisponible) {
        self.salaSeleccionada = sala
    }
    
    // Confirmar reserva enviando a la API
    func confirmarReserva() {
        guard let sala = salaSeleccionada else { return }
        let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin    = combinando(fecha: fechaFin, con: horaSalida)
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
    
//    static func make(onReservar: ((SalaDisponible, Date, Date) -> Void)? = nil) -> BuscadorViewModel {
//        let repo         = RealRoomRepository()
//        let buscar       = BuscarCubiculosDisponiblesUseCase(repository: repo)
//        let alternativos = ObtenerBloquesAlternativosUseCase(buscarDisponibles: buscar)
//        return BuscadorViewModel(buscarDisponibles: buscar, onReservar: onReservar)
//    }
    
    // Modify the `make` function to accept a repository, defaulting to the Real one
    static func make(
        repo: CubiculoRepositoryProtocol = RealRoomRepository(),
        onReservar: ((SalaDisponible, Date, Date) -> Void)? = nil
    ) -> BuscadorViewModel {
        let buscar = BuscarCubiculosDisponiblesUseCase(repository: repo)
        let alternativos = ObtenerBloquesAlternativosUseCase(buscarDisponibles: buscar)
        return BuscadorViewModel(buscarDisponibles: buscar, onReservar: onReservar)
    }

    
    
    func combinar(fecha: Date, hora: Date) -> Date {
        let calendar = Calendar.current
        let componentesFecha = calendar.dateComponents([.year, .month, .day], from: fecha)
        let componentesHora = calendar.dateComponents([.hour, .minute], from: hora)
        
        var final = DateComponents()
        final.year = componentesFecha.year
        final.month = componentesFecha.month
        final.day = componentesFecha.day
        final.hour = componentesHora.hour
        final.minute = componentesHora.minute
        
        return calendar.date(from: final) ?? Date()
    }
}
