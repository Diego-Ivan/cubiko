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
    

    // MARK: - Crear reserva

    @discardableResult
    func crearReserva(sala: SalaDisponible, inicio: Date, fin: Date) -> String? {
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

        let cal = Calendar.current
        let horaInicioComps = cal.dateComponents([.hour, .minute], from: inicio)
        let horaFinComps = cal.dateComponents([.hour, .minute], from: fin)
        
        let reservaActualizada = Reserva(
            id: reservaActual.id,
            estudianteId: 1, // Simulado
            salaUbicacion: reservaActual.salaUbicacion,
            salaNumero: reservaActual.salaNumero,
            fechaInicio: inicio,
            fechaFin: fin,
            horaInicio: horaInicioComps,
            horaFin: horaFinComps,
            numPersonas: 1,
            status: .activa
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
    func extenderReserva(hasta nuevaFin: Date) {
            guard let reserva = reservaActiva else { return }
            isProcessing = true
            
            Task {
                // Le pasamos la reserva completa al caso de uso
                let resultado = await extenderReservaUseCase.execute(reservaActiva: reserva, nuevaFin: nuevaFin)
                
                isProcessing = false
                
                switch resultado {
                case .exito:
                    self.mensajeEstado = "Reserva extendida con éxito"
                    // Aquí podrías actualizar tu objeto reservaActiva localmente si lo deseas
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
            // 1. Le pedimos al backend que cancele la reserva
            let resultado = await cancelarReservaUseCase.execute(reservaId: reserva.id)
            
            isProcessing = false
            
            switch resultado {
            case .exito:
                // 2. Si el backend confirma, limpiamos la UI localmente
                timer?.invalidate()
                timer = nil
                puedeExtender = false
                
                NotificationService.shared.cancelarTodosLosRecordatorios(de: reserva, minutosInicio: 0, minutosFin: 0)
                NotificationService.shared.enviarAhora(.reservaCancelada(reserva: reserva))
                
                self.reservaActiva = nil
                self.mensajeEstado = "Reserva cancelada con éxito"
                
            case .error(let mensaje):
                // Mostrar alerta de que no se pudo cancelar por problemas de red o del servidor
                self.mensajeEstado = "Error al cancelar: \(mensaje)"
            }
        }
    }

    // MARK: - Timer

    private func iniciarTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let reserva = self.reservaActiva else { return }
            let minutosRestantes = reserva.fechaFin.timeIntervalSinceNow / 60
            let minutosParaInicio = reserva.fechaInicio.timeIntervalSinceNow / 60
            Task { @MainActor in
                self.puedeExtender = minutosRestantes <= 20 && minutosRestantes > 0
                self.puedeAjustarHora = minutosParaInicio > 2
                self.comenzarTemporizador = minutosParaInicio <= 0 
            }
        }
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
