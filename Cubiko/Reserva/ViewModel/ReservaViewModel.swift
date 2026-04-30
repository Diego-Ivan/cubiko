//
//  ReservaViewModel.swift
//  Cubiko
//

import Foundation

@MainActor
@Observable
final class ReservaViewModel {

    private(set) var reservaActiva: Reserva? = nil
    private(set) var mensajeEstado: String = "Sin reserva activa"
    private(set) var puedeExtender: Bool = false
    private(set) var puedeActivar: Bool = false
    private(set) var puedeAjustarHora: Bool = false
    private(set) var comenzarTemporizador: Bool = false

    private var minutosInicioUsados: Int = 0
    private var minutosFinUsados: Int = 0
    private var timer: Timer?
    private var isProcessing: Bool = false

    // MARK: - Dependencias (Clean Architecture)
    private let cancelarReservaUseCase: CancelarReservaUseCase
    private let extenderReservaUseCase: ExtenderReservaUseCase

    // MARK: - Init
    init(
        reservaActiva: Reserva,
        cancelarReservaUseCase: CancelarReservaUseCase,
        extenderReservaUseCase: ExtenderReservaUseCase
    ) {
        self.reservaActiva = reservaActiva
        self.cancelarReservaUseCase = cancelarReservaUseCase
        self.extenderReservaUseCase = extenderReservaUseCase
        iniciarTimer()
    }

    func actualizarReservaActiva(_ nuevaReserva: Reserva) {
        self.reservaActiva = nuevaReserva
        evaluarEstadoLocal()
    }

    // MARK: - Actualizar hora (tras reprogramación exitosa)

    func actualizarHora(inicio: Date, fin: Date) {
        guard let reservaActual = reservaActiva else { return }

        NotificationService.shared.cancelarTodosLosRecordatorios(
            de: reservaActual,
            minutosInicio: minutosInicioUsados,
            minutosFin: minutosFinUsados
        )

        let cal = Calendar.current
        let horaInicioComps = cal.dateComponents([.hour, .minute], from: inicio)
        let horaFinComps = cal.dateComponents([.hour, .minute], from: fin)

        let reservaActualizada = Reserva(
            id: reservaActual.id,
            estudianteId: reservaActual.estudianteId,
            salaUbicacion: reservaActual.salaUbicacion,
            salaNumero: reservaActual.salaNumero,
            fechaInicio: inicio,
            fechaFin: fin,
            horaInicio: horaInicioComps,
            horaFin: horaFinComps,
            numPersonas: reservaActual.numPersonas,
            status: reservaActual.status
        )

        reservaActiva = reservaActualizada

        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        mensajeEstado = "\(f.string(from: inicio)) – \(f.string(from: fin))"

        NotificationService.shared.programarRecordatoriosDeReserva(reservaActualizada)
        iniciarTimer()
    }

    // MARK: - Extender reserva
    func extenderReserva(hasta nuevaFin: Date) {
        guard let reserva = reservaActiva else { return }
        isProcessing = true

        Task {
            let resultado = await extenderReservaUseCase.execute(reservaActiva: reserva, nuevaFin: nuevaFin)
            isProcessing = false

            switch resultado {
            case .exito:
                self.mensajeEstado = "Reserva extendida con éxito"
            case .error(let mensaje):
                self.mensajeEstado = "Error al extender: \(mensaje)"
            }
        }
    }

    // MARK: - Cancelar
    func cancelarReserva() {
        guard let reserva = reservaActiva else { return }
        isProcessing = true

        Task {
            let resultado = await cancelarReservaUseCase.execute(reservaId: reserva.id)
            isProcessing = false

            switch resultado {
            case .exito:
                timer?.invalidate()
                timer = nil
                puedeExtender = false

                NotificationService.shared.cancelarTodosLosRecordatorios(de: reserva, minutosInicio: 0, minutosFin: 0)
                NotificationService.shared.enviarAhora(.reservaCancelada(reserva: reserva))

                self.reservaActiva = nil
                self.mensajeEstado = "Reserva cancelada con éxito"

            case .error(let mensaje):
                self.mensajeEstado = "Error al cancelar: \(mensaje)"
            }
        }
    }

    // MARK: - Timer

    private func iniciarTimer() {
        timer?.invalidate()
        evaluarEstadoLocal() // Llamada inicial inmediata
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let reserva = self.reservaActiva else { return }
            let minutosRestantes = reserva.fechaHoraFin.timeIntervalSinceNow / 60
            let minutosParaInicio = reserva.fechaHoraInicio.timeIntervalSinceNow / 60
            Task { @MainActor in
                self.puedeExtender = minutosRestantes <= 20 && minutosRestantes > 0
                self.puedeAjustarHora = minutosParaInicio > 2
                self.comenzarTemporizador = minutosParaInicio <= 0 && reserva.status == .activa
                self.puedeActivar = minutosParaInicio <= 5 && minutosParaInicio >= -5
            }
            self.evaluarEstadoLocal()
        }
    }
    
    private func evaluarEstadoLocal() {
        guard let reserva = self.reservaActiva else { return }
        let minutosRestantes = reserva.fechaHoraFin.timeIntervalSinceNow / 60
        let minutosParaInicio = reserva.fechaHoraInicio.timeIntervalSinceNow / 60
        Task { @MainActor in
            self.puedeExtender = minutosRestantes <= 20 && minutosRestantes > 0
            self.puedeAjustarHora = minutosParaInicio > 2
            self.comenzarTemporizador = minutosParaInicio <= 0 && reserva.status == .activa
            
            self.puedeActivar = minutosParaInicio <= 5 && minutosParaInicio >= -5 && reserva.status == .reservada
        }
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
