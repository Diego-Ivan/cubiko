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
    @Published var errorMessage: String? = nil
    @Published var showErrorAlert = false

    @Published private(set) var estado: BuscadorEstado = .inicial

    var onReservar: ((SalaDisponible, Date, Date, BuscadorViewModel) -> Void)?

    // Use Cases
    private let buscarDisponibles: BuscarCubiculosDisponiblesUseCase

    init(
        buscarDisponibles: BuscarCubiculosDisponiblesUseCase,
        onReservar: ((SalaDisponible, Date, Date, BuscadorViewModel) -> Void)? = nil
    ) {
        self.buscarDisponibles = buscarDisponibles
        self.onReservar = onReservar
    }

    func buscar() {
        Task {
            let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
            let fin    = combinando(fecha: fechaSeleccionada, con: horaSalida)
            
            do {
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
    
    func seleccionarSala(_ sala: SalaDisponible) {
        self.salaSeleccionada = sala
    }
    
    func confirmarReserva() {
        guard let sala = salaSeleccionada else { return }
        let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin    = combinando(fecha: fechaFin, con: horaSalida)
        onReservar?(sala, inicio, fin, self)
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

    static func make(
        repo: CubiculoRepositoryProtocol = RealRoomRepository(),
        onReservar: ((SalaDisponible, Date, Date, BuscadorViewModel) -> Void)? = nil
    ) -> BuscadorViewModel {
        let buscar = BuscarCubiculosDisponiblesUseCase(repository: repo)
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
