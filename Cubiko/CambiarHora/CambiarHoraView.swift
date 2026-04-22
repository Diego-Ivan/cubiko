//
//  CambiarHoraView.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import SwiftUI

struct CambiarHoraView: View {

    @StateObject private var vm: CambiarHoraViewModel

    @State private var mostrarEntrada = false
    @State private var mostrarSalida  = false

    init(
        reservaActiva: Reserva,
        onConfirmar: @escaping (Date, Date) -> Void,
        onCancelar: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: CambiarHoraViewModel.make(
            reservaActiva: reservaActiva,
            onConfirmar: onConfirmar,
            onCancelar: onCancelar
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            pickers
            TimelineDisponibilidadView(vm: vm)
                .padding(.top, 24)
                .padding(.horizontal)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: vm.horaEntrada) { _, _ in vm.validar() }
        .onChange(of: vm.horaSalida)  { _, _ in vm.validar() }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Hora de reserva")
                .font(.headline)

            HStack {
                Button(action: vm.onCancelar) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: vm.confirmar) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.cubikoAzulOscuro)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Pickers

    private var pickers: some View {
        VStack(spacing: 0) {
            FilaCampo(label: "Hora de entrada", valor: vm.horaEntrada.formateadaHora()) {
                mostrarEntrada.toggle()
                mostrarSalida = false
            }
            if mostrarEntrada {
                DatePicker("", selection: $vm.horaEntrada, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }

            Divider().padding(.leading)

            FilaCampo(label: "Hora de salida", valor: vm.horaSalida.formateadaHora()) {
                mostrarSalida.toggle()
                mostrarEntrada = false
            }
            if mostrarSalida {
                DatePicker("", selection: $vm.horaSalida, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }

            Divider().padding(.leading)

            HStack {
                Text("Disponibilidad")
                    .foregroundColor(.primary)
                Spacer()
                DisponibilidadBadge(estado: vm.disponibilidad)
            }
            .padding(.horizontal)
            .padding(.vertical, 14)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.top, 16)
        .animation(.easeInOut(duration: 0.25), value: mostrarEntrada)
        .animation(.easeInOut(duration: 0.25), value: mostrarSalida)
    }
}

// MARK: - Preview

#Preview {
    let cubiculo = Cubiculo(id: 1, nombre: "Sala #1", tipo: "Individual")
    let ahora    = Date()
    let reserva  = Reserva(
        id: UUID(),
        cubiculo: cubiculo,
        inicio: ahora.addingTimeInterval(3600),
        fin: ahora.addingTimeInterval(7200)
    )
    return CambiarHoraView(
        reservaActiva: reserva,
        onConfirmar: { inicio, fin in print("Confirmado: \(inicio) – \(fin)") },
        onCancelar:  { print("Cancelado") }
    )
}
