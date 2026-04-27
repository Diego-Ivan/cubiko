//
//  CambiarHoraViewModel.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import Foundation
import Combine
internal import System

@MainActor
final class CambiarHoraViewModel: ObservableObject {
    
    @Published var horaEntrada: Date
    @Published var horaSalida: Date
    @Published var disponibilidad: DisponibilidadEstado = .libre

    let reservaActiva: Reserva
    let onConfirmar: (Date, Date) -> Void
    let onCancelar: () -> Void

    // 👇 Usamos el Caso de Uso en lugar del repositorio directamente
    private let validarCambioHora: ValidarCambioHoraUseCase
    private var validationTask: Task<Void, Never>?

    init(
        reservaActiva: Reserva,
        validarCambioHora: ValidarCambioHoraUseCase, // Lo inyectamos aquí
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) {
        self.reservaActiva = reservaActiva
        self.validarCambioHora = validarCambioHora
        self.onConfirmar = onConfirmar
        self.onCancelar = onCancelar
        
        self.horaEntrada = reservaActiva.fechaInicio
        // Usamos fechaFin si existe, si no, le sumamos 1 hora a la de inicio
        self.horaSalida = reservaActiva.fechaFin ?? reservaActiva.fechaInicio.addingTimeInterval(3600)
    }

    func validar() {
        validationTask?.cancel()
        disponibilidad = .validando

        validationTask = Task {
            do {
                // Nuestro debounce (esperamos medio segundo)
                try await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }

                // 👇 ¡Toda la lógica pesada se resume a esta sola línea!
                let nuevoEstado = await validarCambioHora.execute(
                    reservaActiva: reservaActiva,
                    nuevaEntrada: horaEntrada,
                    nuevaSalida: horaSalida
                )
                
                guard !Task.isCancelled else { return }
                self.disponibilidad = nuevoEstado
                
            } catch {
                guard !Task.isCancelled else { return }
                self.disponibilidad = .invalido("Error interno")
            }
        }
    }

    func confirmar() {
        guard disponibilidad == .libre else { return }
        onConfirmar(horaEntrada, horaSalida)
    }

    // MARK: - Factory
//    static func make(
//        reservaActiva: Reserva,
//        onConfirmar: @escaping (Date, Date) -> Void,
//        onCancelar: @escaping () -> Void
//    ) -> CambiarHoraViewModel {
//        
//        let repo = CubiculoRepositoryImpl()
//        let validarUseCase = ValidarCambioHoraUseCase(repository: repo)
//        
//        return CambiarHoraViewModel(
//            reservaActiva: reservaActiva,
//            validarCambioHora: validarUseCase,
//            onConfirmar: onConfirmar,
//            onCancelar: onCancelar
//        )
//    }

    // MARK: - Factory
    static func make(
        reservaActiva: Reserva,
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) -> CambiarHoraViewModel {
        // Aquí inyectas tu repositorio real
        let repo = RealRoomRepository()
        
        let validarUseCase = ValidarCambioHoraUseCase(repository: repo)
        
        return CambiarHoraViewModel(
            reservaActiva: reservaActiva,
            validarCambioHora: validarUseCase,
            onConfirmar: onConfirmar,
            onCancelar: onCancelar
        )
    }
}

//@MainActor
//final class CambiarHoraViewModel: ObservableObject {
//
//    // MARK: - Inputs
//    @Published var horaEntrada: Date
//    @Published var horaSalida: Date
//
//    // MARK: - Outputs
//    @Published private(set) var disponibilidad: DisponibilidadEstado = .libre
//
//    // MARK: - Callbacks
//    var onConfirmar: (Date, Date) -> Void
//    var onCancelar: () -> Void
//
//    // MARK: - Deps
//    private let reservaActiva: Reserva
//    private let validarCambioHora: ValidarCambioHoraUseCase
//
//    init(
//        reservaActiva: Reserva,
//        validarCambioHora: ValidarCambioHoraUseCase,
//        onConfirmar: @escaping (Date, Date) -> Void,
//        onCancelar: @escaping () -> Void
//    ) {
//        self.reservaActiva    = reservaActiva
//        self.validarCambioHora = validarCambioHora
//        self.onConfirmar      = onConfirmar
//        self.onCancelar       = onCancelar
//        self.horaEntrada      = reservaActiva.fechaInicio
//        self.horaSalida       = reservaActiva.fechaFin
//    }
//
//    // MARK: - Actions
//
//    func validar() {
//        disponibilidad = validarCambioHora.execute(
//            reservaActiva: reservaActiva,
//            nuevaEntrada: horaEntrada,
//            nuevaSalida: horaSalida
//        )
//    }
//
//    func confirmar() {
//        let resultado = validarCambioHora.execute(
//            reservaActiva: reservaActiva,
//            nuevaEntrada: horaEntrada,
//            nuevaSalida: horaSalida
//        )
//
//        switch resultado {
//        case .libre:
//            print("✅ Horario válido — \(horaEntrada.formateadaHora()) a \(horaSalida.formateadaHora()). Confirmando cambio.")
//            onConfirmar(horaEntrada, horaSalida)
//
//        case .conflicto:
//            print("❌ Conflicto con otra reserva en \(horaEntrada.formateadaHora()) – \(horaSalida.formateadaHora()). Usa el botón ✕ para cancelar.")
//            disponibilidad = .conflicto
//
//        case .invalido(let razon):
//            print("⚠️ Horario inválido: \(razon). Usa el botón ✕ para cancelar.")
//            disponibilidad = .invalido(razon)
//        }
//    }
//
//    // MARK: - Factory
//
//    static func make(
//        reservaActiva: Reserva,
//        onConfirmar: @escaping (Date, Date) -> Void,
//        onCancelar: @escaping () -> Void
//    ) -> CambiarHoraViewModel {
//        let repo    = CubiculoRepositoryImpl()
//        let useCase = ValidarCambioHoraUseCase(repository: repo)
//        return CambiarHoraViewModel(
//            reservaActiva: reservaActiva,
//            validarCambioHora: useCase,
//            onConfirmar: onConfirmar,
//            onCancelar: onCancelar
//        )
//    }
//}
