import SwiftUI

struct ReservaDetalleView: View {
    let reserva: Reserva // La recibe de la lista
    @State private var viewModel: ReservaViewModel
    @State private var mostrarCambiarHora = false
    @State private var mensajeError: String? = nil

    init(reserva: Reserva) {
            self.reserva = reserva
        
        // 1. Instanciamos el repositorio real que hace las peticiones
        // (Usa el nombre de tu clase real, probablemente sea CubiculoRepositoryImpl)
        let repository = RealRoomRepository(baseURL: URL(string: "http://localhost:3001/")!, token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidGlwbyI6ImVzdHVkaWFudGUiLCJlbWFpbCI6ImF6dWFueS5taWxhY25AdWRsYXAubXgiLCJpYXQiOjE3NzY4MjMyNDcsImV4cCI6MTc3NjkwOTY0N30.hF7frRzHMEPUdd8jkAp83NAuAIBCwtuv9hX4Q25w4Bo")
        
        // 2. Creamos los Casos de Uso inyectándoles el repositorio
        let cancelarUseCase = CancelarReservaUseCase(repository: repository)
        let extenderUseCase = ExtenderReservaUseCase(repository: repository)
        
        // 3. Inicializamos el ViewModel con TODAS sus dependencias
        _viewModel = State(wrappedValue: ReservaViewModel(
            reservaActiva: reserva,
            cancelarReservaUseCase: cancelarUseCase,
            extenderReservaUseCase: extenderUseCase
        ))
    }
    
    var body: some View {
        ScrollView {
            if let reservaActiva = viewModel.reservaActiva {
                reservaActivaView(reservaActiva)
            } else {
                Text("No hay información de la reserva")
            }
            // ... botones de cancelar, extender, etc.
        }
        .sheet(isPresented: $mostrarCambiarHora) {
            CambiarHoraView(
                reservaActiva: reserva,
                onConfirmar: { inicio, fin in
                    // Lógica para reprogramar
                    mostrarCambiarHora = false
                },
                onCancelar: { mostrarCambiarHora = false }
            )
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
                            viewModel.extenderReserva(hasta: reserva.fechaFin.addingTimeInterval(30 * 60))
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
                    }
                    .padding(.horizontal)
                    .buttonStyle(CancelButtonStyle())
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
                },
                onCancelar: {
                    mostrarCambiarHora = false
                }
            )
        }
    }

    // MARK: - Crear reserva

    private func reservar(sala: SalaDisponible, inicio: Date, fin: Date) {
        mensajeError = nil
        mensajeError = viewModel.crearReserva(sala: sala, inicio: inicio, fin: fin)
    }
}

#Preview {
    let fechaInicio = Date().addingTimeInterval(10 * 60)
    let fechaFin = Date().addingTimeInterval(20 * 60)
    let calendar = Calendar.current
    let horaInicio = calendar.dateComponents([.hour, .minute], from: fechaInicio)
    let horaFin = calendar.dateComponents([.hour, .minute], from: fechaFin)

    return ReservaDetalleView(reserva: Reserva(
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
