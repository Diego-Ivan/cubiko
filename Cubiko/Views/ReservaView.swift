import SwiftUI

struct ReservaView: View {

    @State private var viewModel = ReservaViewModel()
    @State private var mensajeError: String? = nil
    @State private var mostrarCambiarHora = false

    var body: some View {
        NavigationStack {
            Group {
                if let reserva = viewModel.reservaActiva {
                    reservaActivaView(reserva)
                } else {
                    BuscadorView(onReservar: reservar)
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

                TiempoRestanteView(fechaFin: reserva.fin)

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

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .sheet(isPresented: $mostrarCambiarHora) {
            CambiarHoraView(
                reservaActiva: reserva,
                onConfirmar: { inicio, fin in
                    mostrarCambiarHora = false
                    // TODO: conectar con viewModel.actualizarHora(inicio:fin:)
                    print("Nueva hora: \(inicio) – \(fin)")
                },
                onCancelar: {
                    mostrarCambiarHora = false
                }
            )
        }
    }

    // MARK: - Crear reserva

    private func reservar(cubiculo: Cubiculo, inicio: Date, fin: Date) {
        mensajeError = viewModel.crearReserva(cubiculo: cubiculo, inicio: inicio, fin: fin)
    }
}

#Preview {
    ReservaView()
}
