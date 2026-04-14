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
    @Published var horaSalida: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!

    // MARK: - Outputs
    @Published private(set) var estado: BuscadorEstado = .inicial

    // MARK: - Use Cases
    private let buscarDisponibles: BuscarCubiculosDisponiblesUseCase
    private let obtenerAlternativos: ObtenerBloquesAlternativosUseCase

    // MARK: - Init
    init(
        buscarDisponibles: BuscarCubiculosDisponiblesUseCase,
        obtenerAlternativos: ObtenerBloquesAlternativosUseCase
    ) {
        self.buscarDisponibles = buscarDisponibles
        self.obtenerAlternativos = obtenerAlternativos
    }

    // MARK: - Actions
    func buscar() {
        let inicio = combinando(fecha: fechaSeleccionada, con: horaEntrada)
        let fin    = combinando(fecha: fechaSeleccionada, con: horaSalida)

        let disponibles = buscarDisponibles.execute(inicio: inicio, fin: fin)

        if !disponibles.isEmpty {
            estado = .disponible(disponibles)
        } else {
            let alternativas = obtenerAlternativos.execute(inicio: inicio, fin: fin)
            estado = .sinDisponibilidad(alternativas)
        }
    }

    func seleccionarBloque(_ bloque: BloqueHorario) {
        horaEntrada = bloque.horaInicio
        horaSalida  = bloque.horaFin
        buscar()
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
}

// MARK: - Factory
extension BuscadorViewModel {
    static func makeDefault() -> BuscadorViewModel {
        let repo       = CubiculoRepositoryImpl()
        let buscar     = BuscarCubiculosDisponiblesUseCase(repository: repo)
        let alternativos = ObtenerBloquesAlternativosUseCase(buscarDisponibles: buscar)
        return BuscadorViewModel(buscarDisponibles: buscar, obtenerAlternativos: alternativos)
    }
}
