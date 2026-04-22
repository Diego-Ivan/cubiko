import SwiftUI

struct ReservaView: View {

    @State private var viewModel = ReservaViewModel()
    let reserva: Reserva
        
    @State private var mensajeError: String? = nil
    @State private var mostrarCambiarHora = false

    var body: some View {
        NavigationStack {
            Group {
                if let reserva = viewModel.reservaActiva {
                    reservaActivaView(reserva)
                } else {
                    VStack(spacing: 0) {
                        BuscadorView(onReservar: reservar)

                        if let error = mensajeError {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: mensajeError)
                }
            }
            .navigationTitle(viewModel.reservaActiva == nil ? "Nueva Reserva" : "Mi Reserva")
            .animation(.easeInOut, value: viewModel.reservaActiva == nil)
        }
    }

    // MARK: - Reserva activa

    private func reservaActivaView(_ reserva: Reserva) -> some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {

                ReservaCard(reserva: reserva)
                    .padding(.horizontal)

                TiempoRestanteView(fechaFin: reserva.fechaFin)

                // Ayuda y soporte
                HStack {
                    Text("Ayuda y soporte")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    print("Ayuda y soporte tapped")
                }
                .padding(.horizontal)

                // Botones
                VStack(spacing: 10) {

                    // Botón extender — aparece cuando faltan <= 20 min
                    if viewModel.puedeExtender {
                        Button {
                            viewModel.extenderReserva(minutos: 30)
                        } label: {
                            HStack {
                                Image(systemName: "clock.badge.plus")
                                Text("Extender 30 minutos")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.cubikoAzulOscuro)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Button {
                        mostrarCambiarHora = true
                    } label: {
                        Text("Cambiar hora de reserva")
                    }
                    .padding(.horizontal)
                    .buttonStyle(TertiaryButtonStyle())

                    Button {
                        viewModel.cancelarReserva()
                    } label: {
                        Text("Cancelar reserva")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red.opacity(0.15))
                            )
                    }
                    .padding(.horizontal)
                }
                .padding()
                .animation(.easeInOut(duration: 0.4), value: viewModel.puedeExtender)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .sheet(isPresented: $mostrarCambiarHora) {
            CambiarHoraView(
                reservaActiva: reserva,
                onConfirmar: { inicio, fin in
                    mostrarCambiarHora = false
                    viewModel.actualizarHora(inicio: inicio, fin: fin)
                },
                onCancelar: {
                    mostrarCambiarHora = false
                }
            )
        }
    }

    // MARK: - Crear reserva

    private func reservar(cubiculo: Cubiculo, inicio: Date, fin: Date) {
        mensajeError = nil
        mensajeError = viewModel.crearReserva(cubiculo: cubiculo, inicio: inicio, fin: fin)
    }
}

#Preview {
    let fechaInicio = Date().addingTimeInterval(10 * 60)
    let fechaFin = Date().addingTimeInterval(20 * 60)
    let calendar = Calendar.current
    let horaInicio = calendar.dateComponents([.hour, .minute], from: fechaInicio)
    let horaFin = calendar.dateComponents([.hour, .minute], from: fechaFin)

    return ReservaView(reserva: Reserva(
        id: 1,
        estudianteId: 2,
        salaUbicacion: "Piso 1",
        salaNumero: 21,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        horaInicio: horaInicio,
        horaFin: horaFin,
        numPersonas: 2
    ))

}
