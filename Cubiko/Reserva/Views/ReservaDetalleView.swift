import SwiftUI

struct ReservaDetalleView: View {
    @Binding var reserva: Reserva
    @Binding var vmReservas: ReservasViewModel
    var onCancelacion: (() -> Void)? = nil
    @State private var viewModel: ReservaViewModel
    @State private var mostrarCambiarHora = false
    @State private var mostrarAlertaCancelacion = false
    @State private var mostrarCamara = false
    
    @State private var cancelando = false
    @Environment(\.dismiss) private var dismiss


    init(reserva: Binding<Reserva>, vmReservas: Binding<ReservasViewModel>, onCancelacion: (() -> Void)? = nil) {
        _reserva = reserva
        _vmReservas = vmReservas
        
        let repository = RealRoomRepository()
        let cancelarUseCase = CancelarReservaUseCase(repository: repository)
        let extenderUseCase = ExtenderReservaUseCase(repository: repository)
        
        _viewModel = State(wrappedValue: ReservaViewModel(
            reservaActiva: reserva.wrappedValue,
            cancelarReservaUseCase: cancelarUseCase,
            extenderReservaUseCase: extenderUseCase
        ))
    }
    
    var body: some View {
        NavigationStack {
            if cancelando {
                VStack {
                    ProgressView()
                    Text("Cancelando reserva")
                }
            } else {
                ScrollView {
                    reservaActivaView(reserva)
                }
                .navigationTitle("Mi Reserva")
            }
        }
        .onChange(of: reserva) {
            viewModel.actualizarReservaActiva(reserva)
        }
        .sheet(isPresented: $mostrarCambiarHora) {
            CambiarHoraView(
                reservaActiva: reserva,
                onConfirmar: { inicio, fin in
                    mostrarCambiarHora = false
                },
                onCancelar: { mostrarCambiarHora = false }
            )
        }
        .onChange(of: viewModel.reservaActiva) {
            if viewModel.reservaActiva == nil {
                cancelando = false
                onCancelacion?()
                dismiss()
            }
        }
        .sheet(isPresented: $mostrarCamara, onDismiss: {
            Task {
                guard let actualizada = await vmReservas.refreshReserva(id: reserva.id) else {
                    return // error de red, no hacer nada
                }
                if actualizada.status == .completada || actualizada.status == .cancelada {
                    // Reserva finalizada → cerrar primero, refrescar lista después
                    onCancelacion?()
                    dismiss()
                    // Refrescar la lista DESPUÉS del dismiss para evitar crash
                    // de Index out of range en ReservasView
                    vmReservas.fetchReservasActuales()
                } else {
                    // Status cambió (ej. .reservada → .activa) → actualizar UI
                    reserva = actualizada
                    viewModel.actualizarReservaActiva(actualizada)
                    vmReservas.fetchReservasActuales()
                }
            }
        }) {
            CameraView(viewModel: vmReservas)
        }
    }

    // MARK: - Reserva activa

    private func reservaActivaView(_ reserva: Reserva) -> some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {

                ReservaCard(reserva: reserva)
                
                if viewModel.comenzarTemporizador {
                    TiempoRestanteView(fechaFin: reserva.fechaHoraFin)
                }

                if reserva.numPersonas > 1 {
                    NavigationLink(destination: CompartirReservaView(reserva: reserva)) {
                        Text("Añadir personas")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }

                NavigationLink(destination: EmptyView()) {
                    Text("Ayuda y soporte")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                Spacer()
                
                VStack(spacing: 10) {
                    
                    if viewModel.puedeActivar {
                        
                        Button {
                            mostrarCamara.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "qrcode")
                                Text("Activar reserva")
                            }
                        }
                        .padding(.horizontal)
                        .buttonStyle(PrimaryButtonStyle())

                    }

                    if viewModel.puedeExtender {
                        Button {
                            viewModel.extenderReserva(hasta: reserva.fechaFin.addingTimeInterval(30 * 60))
                        } label: {
                            HStack {
                                Image(systemName: "clock.badge.plus")
                                Text("Extender 30 minutos")
                            }
                        }
                        .padding(.horizontal)
                        .buttonStyle(PrimaryButtonStyle())
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
                    
                    if viewModel.reservaActiva?.status == .reservada {
                        Button {
                            mostrarAlertaCancelacion = true
                        } label: {
                            Text("Cancelar reserva")
                        }
                        .padding(.horizontal)
                        .buttonStyle(CancelButtonStyle())
                    }

                    if viewModel.reservaActiva?.status == .activa {
                        Button {
                            mostrarCamara.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "qrcode")
                                Text("Terminar reserva")
                            }
                        }
                        .padding(.horizontal)
                        .buttonStyle(PrimaryButtonStyle())
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .padding()
        }
        .alert("¿Cancelar reserva?", isPresented: $mostrarAlertaCancelacion) {
            Button("Sí, cancelar", role: .destructive) {
                viewModel.cancelarReserva()
                self.cancelando = true
            }
            Button("No", role: .cancel) {}
        } message: {
            Text("Esta acción liberará la sala y no se podrá deshacer.")
        }
    }
}
