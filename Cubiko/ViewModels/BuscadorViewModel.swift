//
//  BuscadorViewModel.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import Foundation
import Combine

enum BuscadorEstado {
    case inicial
    case disponible([Cubiculo])
    case sinDisponibilidad([BloqueHorario])
}

@MainActor
final class BuscadorViewModel: ObservableObject {
    
    // MARK: - Inputs
    @Published var fechaSeleccionada: Date = Date()
    @Published var horaEntrada: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @Published var horaSalida: Date  = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!

    // MARK: - Outputs
    @Published private(set) var estado: BuscadorEstado = .inicial

    // MARK: - Callback
    var onReservar: ((Cubiculo, Date, Date) -> Void)?

    // MARK: - Use Cases
    private let buscarDisponibles: BuscarCubiculosDisponiblesUseCase
    private let obtenerAlternativos: ObtenerBloquesAlternativosUseCase

    init(
        buscarDisponibles: BuscarCubiculosDisponiblesUseCase,
        obtenerAlternativos: ObtenerBloquesAlternativosUseCase,
        onReservar: ((Cubiculo, Date, Date) -> Void)? = nil
    ) {
        self.buscarDisponibles   = buscarDisponibles
        self.obtenerAlternativos = obtenerAlternativos
        self.onReservar          = onReservar
    }

    // MARK: - Actions
    func buscar() {
        let inicio      = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin         = combinando(fecha: fechaSeleccionada, con: horaSalida)
        let disponibles = buscarDisponibles.execute(inicio: inicio, fin: fin)

        if !disponibles.isEmpty {
            estado = .disponible(disponibles)
        } else {
            estado = .sinDisponibilidad(obtenerAlternativos.execute(inicio: inicio, fin: fin))
        }
    }

    func seleccionarBloque(_ bloque: BloqueHorario) {
        horaEntrada = bloque.horaInicio
        horaSalida  = bloque.horaFin
        buscar()
    }

    func seleccionarCubiculo(_ cubiculo: Cubiculo) {
        let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin    = combinando(fecha: fechaSeleccionada, con: horaSalida)
        print("✅ seleccionarCubiculo llamado — onReservar es nil: \(onReservar == nil)")
        onReservar?(cubiculo, inicio, fin)
    }

    func combinando(fecha: Date, con hora: Date) -> Date {
        let cal = Calendar.current
        let hc  = cal.dateComponents([.hour, .minute], from: hora)
        return cal.date(bySettingHour: hc.hour ?? 0,
                        minute: hc.minute ?? 0,
                        second: 0,
                        of: fecha) ?? fecha
    }

    // MARK: - Factory
    static func make(onReservar: ((Cubiculo, Date, Date) -> Void)? = nil) -> BuscadorViewModel {
        let repo         = CubiculoRepositoryImpl()
        let buscar       = BuscarCubiculosDisponiblesUseCase(repository: repo)
        let alternativos = ObtenerBloquesAlternativosUseCase(buscarDisponibles: buscar)
        return BuscadorViewModel(buscarDisponibles: buscar, obtenerAlternativos: alternativos, onReservar: onReservar)
    }
}
