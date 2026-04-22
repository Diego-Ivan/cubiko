//
//  NuevaReservaView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import SwiftUI
import UserNotifications

// MARK: - Fila con DatePicker expandible

private struct FilaFechaPicker: View {

    let titulo: String
    let icono: String
    let componentes: DatePickerComponents
    @Binding var fecha: Date
    @Binding var filaExpandida: String
    let id: String

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                filaExpandida = (filaExpandida == id) ? "" : id
            }
        } label: {
            HStack {
                Label(titulo, systemImage: icono)
                    .foregroundStyle(.primary)
                Spacer()
                Text(fecha, format: componentes == .date
                     ? .dateTime.day().month().year()
                     : .dateTime.hour().minute())
                    .foregroundStyle(filaExpandida == id ? .blue : .secondary)
            }
        }

        if filaExpandida == id {
            DatePicker(
                "",
                selection: $fecha,
                in: Date()...,
                displayedComponents: componentes
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
        }
    }
}

// MARK: - Vista principal

struct PruebaNotificacionesView: View {

    @State private var viewModel = ReservaViewModel()
    @State private var fechaInicio = Date().addingTimeInterval(10 * 60)
    @State private var fechaFin    = Date().addingTimeInterval(70 * 60)
    @State private var filaExpandida: String = ""
    @State private var mensajeError: String? = nil

    // Para el diagnóstico
    @State private var estadoPermisos: String = "Sin verificar"
    @State private var notificacionesPendientes: [String] = []

    var body: some View {
        NavigationView {
            List {

                // MARK: Estado actual
                if let reserva = viewModel.reservaActiva {
                    Section {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(reserva.cubiculo.nombre)
                                    .font(.subheadline).bold()
                                Text(viewModel.mensajeEstado)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: Selección de fecha y hora
                if viewModel.reservaActiva == nil {
                    Section("Nueva reserva") {
                        FilaFechaPicker(
                            titulo: "Fecha",
                            icono: "calendar",
                            componentes: .date,
                            fecha: $fechaInicio,
                            filaExpandida: $filaExpandida,
                            id: "fecha"
                        )
                        .onChange(of: fechaInicio) { _, nueva in
                            let diff = fechaFin.timeIntervalSince(fechaInicio)
                            fechaFin = nueva.addingTimeInterval(max(diff, 3600))
                        }

                        FilaFechaPicker(
                            titulo: "Hora de inicio",
                            icono: "clock",
                            componentes: .hourAndMinute,
                            fecha: $fechaInicio,
                            filaExpandida: $filaExpandida,
                            id: "horaInicio"
                        )

                        FilaFechaPicker(
                            titulo: "Hora de fin",
                            icono: "clock.badge.checkmark",
                            componentes: .hourAndMinute,
                            fecha: $fechaFin,
                            filaExpandida: $filaExpandida,
                            id: "horaFin"
                        )
                    }

                    if let error = mensajeError {
                        Section {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }
                    }
                }

                // MARK: Botón crear / cancelar
                Section {
                    if viewModel.reservaActiva == nil {
                        Button {
                            filaExpandida = ""
                            let cubiculoPrueba = Cubiculo(id: 1, nombre: "Cubículo A-01", tipo: "Individual")
                            mensajeError = viewModel.crearReserva(cubiculo: cubiculoPrueba, inicio: fechaInicio, fin: fechaFin)
                        } label: {
                            Label("Crear reserva", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                    } else {
                        Button(role: .destructive) {
                            viewModel.cancelarReserva()
                        } label: {
                            Label("Cancelar reserva", systemImage: "xmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }

                // MARK: Otras notificaciones
                Section("Probar otras notificaciones") {
                    Button {
                        NotificationService.shared.enviarAhora(
                            .multaPendiente(descripcion: "Tienes una multa de $20 por retraso.")
                        )
                    } label: {
                        Label("Simular multa pendiente", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    }

                    Button {
                        NotificationService.shared.enviarAhora(
                            .materialVencido(nombreMaterial: "Cálculo Vol. II")
                        )
                    } label: {
                        Label("Simular material vencido", systemImage: "book.closed")
                            .foregroundStyle(.red)
                    }
                }

                // MARK: ✅ Debug — ahora SÍ está dentro del body y del List
                Section("🛠️ Debug") {

                    // Estado de permisos con texto visible en pantalla
                    Button("Verificar permisos") {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            DispatchQueue.main.async {
                                switch settings.authorizationStatus {
                                case .notDetermined: estadoPermisos = "⚪ No determinado — nunca se pidió"
                                case .denied:        estadoPermisos = "🔴 DENEGADO — ve a Ajustes"
                                case .authorized:    estadoPermisos = "🟢 Autorizado"
                                case .provisional:   estadoPermisos = "🟡 Provisional"
                                case .ephemeral:     estadoPermisos = "🟡 Efímero"
                                @unknown default:    estadoPermisos = "❓ Desconocido"
                                }
                            }
                        }
                    }

                    // Muestra el resultado en pantalla (no solo en consola)
                    if estadoPermisos != "Sin verificar" {
                        Text(estadoPermisos)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    // Ver notificaciones pendientes en pantalla
                    Button("Ver notificaciones pendientes") {
                        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                            DispatchQueue.main.async {
                                if requests.isEmpty {
                                    notificacionesPendientes = ["(ninguna programada)"]
                                } else {
                                    notificacionesPendientes = requests.map { req in
                                        let hora: String
                                        if let cal = req.trigger as? UNCalendarNotificationTrigger,
                                           let next = cal.nextTriggerDate() {
                                            hora = next.formatted(date: .omitted, time: .shortened)
                                        } else {
                                            hora = "inmediata"
                                        }
                                        return "• \(req.identifier.prefix(30))… → \(hora)"
                                    }
                                }
                            }
                        }
                    }

                    ForEach(notificacionesPendientes, id: \.self) { texto in
                        Text(texto)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Si los permisos están denegados, este botón abre Ajustes directamente
                    if estadoPermisos.contains("DENEGADO") || estadoPermisos.contains("No determinado") {
                        Button("Abrir Ajustes de Cubiko") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundStyle(.blue)
                    }
                }

            }
            .navigationTitle("🔔 Prueba de notificaciones")
            .animation(.easeInOut, value: viewModel.reservaActiva == nil)
        }
    }
}

#Preview {
    PruebaNotificacionesView()
}
