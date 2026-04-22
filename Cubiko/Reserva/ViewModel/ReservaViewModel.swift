//
//  ReservaViewModel.swift
//  Cubiko
//
//  Va en: ViewModels/
//

import Foundation

@MainActor
@Observable
final class ReservaViewModel {

    private(set) var reservaActiva: Reserva? = nil
    private(set) var mensajeEstado: String = "Sin reserva activa"

    // Guardamos los minutos que se usaron al programar,
    // para poder cancelar con los identificadores correctos aunque el usuario
    // cambie la configuración entre medias.
    private var minutosInicioUsados: Int = 0
    private var minutosFinUsados: Int = 0

    // MARK: - Crear reserva

    @discardableResult
    func crearReserva(inicio: Date, fin: Date) -> String? {
        guard fin > inicio else { return "La hora de fin debe ser después del inicio." }
        guard inicio > Date() else { return "La hora de inicio debe ser en el futuro." }

        let cal = Calendar.current
        let horaInicioComps = cal.dateComponents([.hour, .minute], from: inicio)
        let horaFinComps = cal.dateComponents([.hour, .minute], from: fin)
        
        let reserva = Reserva(
            id: Int.random(in: 1...10000), // Simulado
            estudianteId: 1, // Simulado
            salaUbicacion: "Biblioteca Central", // Simulado
            salaNumero: 101, // Simulado
            fechaInicio: inicio,
            fechaFin: fin,
            horaInicio: horaInicioComps,
            horaFin: horaFinComps,
            numPersonas: 1,
            status: .activa
        )

        // Guardar los minutos actuales antes de programar
        minutosInicioUsados = UserDefaults.standard.integer(forKey: "minutosAvisoInicio").nonZero ?? 15
        minutosFinUsados    = UserDefaults.standard.integer(forKey: "minutosAvisoFin").nonZero ?? 15

        reservaActiva = reserva

        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        mensajeEstado = "\(f.string(from: inicio)) – \(f.string(from: fin))"

        NotificationService.shared.programarRecordatoriosDeReserva(reserva)
        NotificationService.shared.enviarAhora(.reservaConfirmada(reserva: reserva))

        return nil
    }

    // MARK: - Cancelar

    func cancelarReserva() {
        guard let reserva = reservaActiva else { return }
        NotificationService.shared.cancelarTodosLosRecordatorios(
            de: reserva,
            minutosInicio: minutosInicioUsados,
            minutosFin: minutosFinUsados
        )
        NotificationService.shared.enviarAhora(.reservaCancelada(reserva: reserva))
        reservaActiva = nil
        mensajeEstado = "Reserva cancelada"
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
