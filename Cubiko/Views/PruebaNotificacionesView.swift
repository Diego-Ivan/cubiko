//
//  PruebaNotificacionesView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

//  Vista temporal para probar el sistema de notificaciones.
//  Puedes eliminarla o integrarla a BuscadorView más adelante.
//

import SwiftUI

struct PruebaNotificacionesView: View {

    @State private var viewModel = ReservaViewModel()
    // Duración en minutos de la reserva simulada
    @State private var duracion: Double = 20

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                // MARK: Estado actual
                GroupBox("Estado") {
                    Text(viewModel.mensajeEstado)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let reserva = viewModel.reservaActiva {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Label(reserva.cubiculo.nombre, systemImage: "building.2")
                            Label("Termina: \(reserva.fin.formatted(date: .omitted, time: .shortened))", systemImage: "clock")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                // MARK: Duración del simulacro
                GroupBox("Duración de la reserva simulada") {
                    VStack {
                        Slider(value: $duracion, in: 1...60, step: 1)
                        Text("\(Int(duracion)) minutos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
                .disabled(viewModel.reservaActiva != nil)

                // MARK: Botones
                VStack(spacing: 12) {

                    Button {
                        viewModel.crearReservaSimulada(duracionMinutos: Int(duracion))
                    } label: {
                        Label("Crear reserva simulada", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.reservaActiva != nil)

                    Button(role: .destructive) {
                        viewModel.cancelarReserva()
                    } label: {
                        Label("Cancelar reserva", systemImage: "xmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.reservaActiva == nil)

                    Divider()

                    // Botones de prueba para otros tipos de notificación
                    Button {
                        NotificationService.shared.enviarAhora(.multaPendiente(descripcion: "Tienes una multa de $20 por retraso."))
                    } label: {
                        Label("Simular multa pendiente", systemImage: "exclamationmark.triangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button {
                        NotificationService.shared.enviarAhora(.materialVencido(nombreMaterial: "Cálculo Vol. II"))
                    } label: {
                        Label("Simular material vencido", systemImage: "book.closed")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding(.horizontal)

                Spacer()

                // Nota sobre los avisos programados
                if viewModel.reservaActiva != nil {
                    GroupBox {
                        Label(
                            "Recibirás avisos 15 y 5 minutos antes de que termine la reserva, incluso si la app está cerrada.",
                            systemImage: "bell.badge"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Prueba de notificaciones")
            .padding(.vertical)
        }
    }
}

#Preview {
    PruebaNotificacionesView()
}
