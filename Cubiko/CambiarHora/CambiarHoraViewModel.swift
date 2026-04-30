//
//  CambiarHoraViewModel.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import Foundation
import Combine

@MainActor
final class CambiarHoraViewModel: ObservableObject {

    // MARK: - Inputs
    @Published var horaEntrada: Date
    @Published var horaSalida: Date

    // MARK: - Outputs
    @Published var disponibilidad: DisponibilidadEstado = .libre

    // MARK: - Callbacks
    let reservaActiva: Reserva
    let onConfirmar: (Date, Date) -> Void
    let onCancelar: () -> Void

    // MARK: - Deps
    private let validarCambioHora: ValidarCambioHoraUseCase
    private var validationTask: Task<Void, Never>?

    // MARK: - Init

    init(
        reservaActiva: Reserva,
        validarCambioHora: ValidarCambioHoraUseCase,
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) {
        self.reservaActiva = reservaActiva
        self.validarCambioHora = validarCambioHora
        self.onConfirmar = onConfirmar
        self.onCancelar = onCancelar
        self.horaEntrada = reservaActiva.fechaInicio
        self.horaSalida = reservaActiva.fechaFin
    }

    // MARK: - Actions

    func validar() {
        validationTask?.cancel()
        disponibilidad = .validando

        validationTask = Task {
            do {
                // Debounce de 500 ms
                try await Task.sleep(nanoseconds: 500_000_000)
                guard !Task.isCancelled else { return }

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

    static func make(
        reservaActiva: Reserva,
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) -> CambiarHoraViewModel {
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
