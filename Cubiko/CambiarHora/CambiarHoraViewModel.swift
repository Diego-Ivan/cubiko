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
    @Published private(set) var disponibilidad: DisponibilidadEstado = .libre

    // MARK: - Callbacks
    var onConfirmar: (Date, Date) -> Void
    var onCancelar: () -> Void

    // MARK: - Deps
    private let reservaActiva: Reserva
    private let validarCambioHora: ValidarCambioHoraUseCase

    init(
        reservaActiva: Reserva,
        validarCambioHora: ValidarCambioHoraUseCase,
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) {
        self.reservaActiva    = reservaActiva
        self.validarCambioHora = validarCambioHora
        self.onConfirmar      = onConfirmar
        self.onCancelar       = onCancelar
        self.horaEntrada      = reservaActiva.inicio
        self.horaSalida       = reservaActiva.fin
    }

    // MARK: - Actions

    func validar() {
        disponibilidad = validarCambioHora.execute(
            reservaActiva: reservaActiva,
            nuevaEntrada: horaEntrada,
            nuevaSalida: horaSalida
        )
    }

    func confirmar() {
        let resultado = validarCambioHora.execute(
            reservaActiva: reservaActiva,
            nuevaEntrada: horaEntrada,
            nuevaSalida: horaSalida
        )

        switch resultado {
        case .libre:
            print("✅ Horario válido — \(horaEntrada.formateadaHora()) a \(horaSalida.formateadaHora()). Confirmando cambio.")
            onConfirmar(horaEntrada, horaSalida)

        case .conflicto:
            print("❌ Conflicto con otra reserva en \(horaEntrada.formateadaHora()) – \(horaSalida.formateadaHora()). Usa el botón ✕ para cancelar.")
            disponibilidad = .conflicto

        case .invalido(let razon):
            print("⚠️ Horario inválido: \(razon). Usa el botón ✕ para cancelar.")
            disponibilidad = .invalido(razon)
        }
    }

    // MARK: - Factory

    static func make(
        reservaActiva: Reserva,
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) -> CambiarHoraViewModel {
        let repo    = CubiculoRepositoryImpl()
        let useCase = ValidarCambioHoraUseCase(repository: repo)
        return CambiarHoraViewModel(
            reservaActiva: reservaActiva,
            validarCambioHora: useCase,
            onConfirmar: onConfirmar,
            onCancelar: onCancelar
        )
    }
}
