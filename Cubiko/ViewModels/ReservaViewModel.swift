//
//  ReservaViewModel.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import Foundation

@MainActor
@Observable
final class ReservaViewModel {

    // La reserva activa (nil si no hay ninguna)
    private(set) var reservaActiva: Reserva? = nil

    // Mensaje de estado para mostrarlo en la UI
    private(set) var mensajeEstado: String = "Sin reserva activa"

    // MARK: - Reserva simulada (para pruebas)

    /// Crea una reserva falsa que termina en `duracionMinutos` minutos
    /// y programa los recordatorios automáticamente.
    func crearReservaSimulada(duracionMinutos: Int = 20) {
        let cubiculoPrueba = Cubiculo(id: 1, nombre: "Cubículo A-01", tipo: "Individual")
        let ahora = Date()
        let fin = ahora.addingTimeInterval(Double(duracionMinutos * 60))

        let reserva = Reserva(
            id: UUID(),
            cubiculo: cubiculoPrueba,
            inicio: ahora,
            fin: fin
        )

        reservaActiva = reserva
        mensajeEstado = "Reserva activa — termina en \(duracionMinutos) min"

        // Programar avisos de 15 y 5 minutos antes del fin
        NotificationService.shared.programarRecordatoriosDeReserva(reserva)

        // También mandar una notificación de confirmación inmediata
        NotificationService.shared.enviarAhora(.reservaConfirmada(reserva: reserva))

        print("Reserva simulada creada. Fin: \(fin)")
    }

    // MARK: - Cancelar reserva

    func cancelarReserva() {
        guard let reserva = reservaActiva else { return }

        NotificationService.shared.cancelarTodosLosRecordatorios(de: reserva)
        NotificationService.shared.enviarAhora(.reservaCancelada(reserva: reserva))

        reservaActiva = nil
        mensajeEstado = "Reserva cancelada"
    }
}
