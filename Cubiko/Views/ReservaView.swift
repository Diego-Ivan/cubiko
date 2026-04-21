import SwiftUI

struct ReservaView: View {

    @State private var viewModel = ReservaViewModel()
    @State private var mensajeError: String? = nil

    var body: some View {
        NavigationView {
            Group {
                if let reserva = viewModel.reservaActiva {
                    reservaActivaView(reserva)
                } else {
                    // ← Pasamos la referencia a través de una función separada
                    BuscadorView(onReservar: reservar)
                }
            }
            .navigationTitle("Nueva Reserva")
            .animation(.easeInOut, value: viewModel.reservaActiva == nil)
        }
    }

    // ← Función separada en lugar de closure inline
    private func reservar(cubiculo: Cubiculo, inicio: Date, fin: Date) {
        mensajeError = viewModel.crearReserva(cubiculo: cubiculo, inicio: inicio, fin: fin)
    }

    private func reservaActivaView(_ reserva: Reserva) -> some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 56))

                Text(reserva.cubiculo.nombre)
                    .font(.title2.bold())

                Text(viewModel.mensajeEstado)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TiempoRestanteView(fechaFin: reserva.fin)

            Spacer()

            Button(role: .destructive) {
                viewModel.cancelarReserva()
            } label: {
                Label("Cancelar reserva", systemImage: "xmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ReservaView()
}
