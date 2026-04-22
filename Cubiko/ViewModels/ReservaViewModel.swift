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
    private(set) var puedeExtender: Bool = false

    private var minutosInicioUsados: Int = 0
    private var minutosFinUsados: Int = 0
    private var timer: Timer?

    // MARK: - Crear reserva

    @discardableResult
    func crearReserva(cubiculo: Cubiculo, inicio: Date, fin: Date) -> String? {
        guard fin > inicio else { return "La hora de fin debe ser después del inicio." }
        guard inicio > Date() else { return "La hora de inicio debe ser en el futuro." }

        let reserva = Reserva(id: UUID(), cubiculo: cubiculo, inicio: inicio, fin: fin)

        minutosInicioUsados = UserDefaults.standard.integer(forKey: "minutosAvisoInicio").nonZero ?? 15
        minutosFinUsados    = UserDefaults.standard.integer(forKey: "minutosAvisoFin").nonZero ?? 15

        reservaActiva = reserva

        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        mensajeEstado = "\(f.string(from: inicio)) – \(f.string(from: fin))"

        NotificationService.shared.programarRecordatoriosDeReserva(reserva)
        NotificationService.shared.enviarAhora(.reservaConfirmada(reserva: reserva))

        iniciarTimer()
        return nil
    }

    // MARK: - Actualizar hora

    func actualizarHora(inicio: Date, fin: Date) {
        guard let reservaActual = reservaActiva else { return }

        NotificationService.shared.cancelarTodosLosRecordatorios(
            de: reservaActual,
            minutosInicio: minutosInicioUsados,
            minutosFin: minutosFinUsados
        )

        let reservaActualizada = Reserva(
            id: reservaActual.id,
            cubiculo: reservaActual.cubiculo,
            inicio: inicio,
            fin: fin
        )

        reservaActiva = reservaActualizada

        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        mensajeEstado = "\(f.string(from: inicio)) – \(f.string(from: fin))"

        NotificationService.shared.programarRecordatoriosDeReserva(reservaActualizada)

        print("✅ Hora actualizada: \(f.string(from: inicio)) – \(f.string(from: fin))")
        iniciarTimer()
    }

    // MARK: - Extender reserva

    func extenderReserva(minutos: Int = 30) {
        guard let reservaActual = reservaActiva, puedeExtender else { return }

        let nuevaFin = reservaActual.fin.addingTimeInterval(Double(minutos) * 60)

        NotificationService.shared.cancelarTodosLosRecordatorios(
            de: reservaActual,
            minutosInicio: minutosInicioUsados,
            minutosFin: minutosFinUsados
        )

        let reservaExtendida = Reserva(
            id: reservaActual.id,
            cubiculo: reservaActual.cubiculo,
            inicio: reservaActual.inicio,
            fin: nuevaFin
        )

        reservaActiva = reservaExtendida

        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        mensajeEstado = "\(f.string(from: reservaExtendida.inicio)) – \(f.string(from: nuevaFin))"

        NotificationService.shared.programarRecordatoriosDeReserva(reservaExtendida)

        print("✅ Reserva extendida hasta: \(f.string(from: nuevaFin))")
        iniciarTimer()
    }

    // MARK: - Cancelar

    func cancelarReserva() {
        timer?.invalidate()
        timer = nil
        puedeExtender = false

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

    // MARK: - Timer

    private func iniciarTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let reserva = self.reservaActiva else { return }
            let minutosRestantes = reserva.fin.timeIntervalSinceNow / 60
            Task { @MainActor in
                self.puedeExtender = minutosRestantes <= 20 && minutosRestantes > 0
            }
        }
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
