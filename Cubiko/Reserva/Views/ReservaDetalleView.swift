import SwiftUI

struct ReservaDetalleView: View {
    let reserva: Reserva // La recibe de la lista
    @State private var viewModel: ReservaViewModel
    @State private var mostrarQR = false
    @State private var mostrarCambiarHora = false
    @State private var mostrarAlertaCancelacion = false
    @State private var mensajeError: String? = nil
    
    @Environment(\.dismiss) private var dismiss

    init(reserva: Reserva) {
            self.reserva = reserva
        
        // 1. Instanciamos el repositorio real que hace las peticiones
        // (Usa el nombre de tu clase real, probablemente sea CubiculoRepositoryImpl)
        let repository = RealRoomRepository()
        
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
        NavigationStack{
            ScrollView {
                if let reservaActiva = viewModel.reservaActiva {
                    reservaActivaView(reservaActiva)
                        .sheet(isPresented: $mostrarQR) {
                            VistaQRView()
                                .presentationSizing(.fitted)
                        }
                } else {
                    Text("No hay información de la reserva")
                }
                // ... botones de cancelar, extender, etc.
            }
        }
        .navigationTitle("Mi Reserva")
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
        .onChange(of: viewModel.reservaActiva) { oldValue, newValue in
            // Si la reserva se vuelve nil (ej. se canceló con éxito), regresamos a la pantalla anterior
            if newValue == nil {
                dismiss()
            }
        }
    }

    // MARK: - Reserva activa

    private func reservaActivaView(_ reserva: Reserva) -> some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {

                ReservaCard(reserva: reserva)
                    .padding(.horizontal)
                    .onTapGesture {
                        mostrarQR = true
                    }

                if viewModel.comenzarTemporizador {
                    TiempoRestanteView(fechaFin: reserva.fechaFin)
                }

                // Ayuda y soporte
                NavigationLink(destination: EmptyView()) {
                    Text("Ayuda y soporte")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()

                .padding(.horizontal)

                Spacer()
                
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
                            .background(Color.primaryCubiko)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if (viewModel.puedeAjustarHora) {
                        Button {
                            mostrarCambiarHora = true
                        } label: {
                            Text("Cambiar hora de reserva")
                        }
                        .padding(.horizontal)
                        .buttonStyle(TertiaryButtonStyle())
                    }
                    
                    Button {
                        mostrarAlertaCancelacion = true
                    } label: {
                        Text("Cancelar reserva")
                    }
                    .padding(.horizontal)
                    .buttonStyle(CancelButtonStyle())
                }
                .padding()
                .animation(.easeInOut(duration: 0.4), value: viewModel.puedeExtender)

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
//            .presentationDetents([.fraction(0.5)])
        }
        .alert("¿Cancelar reserva?", isPresented: $mostrarAlertaCancelacion) {
            Button("Sí, cancelar", role: .destructive) {
                viewModel.cancelarReserva()
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("Esta acción liberará la sala y no se podrá deshacer.")
        }
    }

    // MARK: - Crear reserva

    private func reservar(sala: SalaDisponible, inicio: Date, fin: Date) {
        mensajeError = nil
        mensajeError = viewModel.crearReserva(sala: sala, inicio: inicio, fin: fin)
    }
}

#Preview {
    let fechaInicio = Date().addingTimeInterval(60 * 60)
    let fechaFin = Date().addingTimeInterval(120 * 60)
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
