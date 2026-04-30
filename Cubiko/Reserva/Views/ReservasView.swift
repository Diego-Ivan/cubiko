//
//  ReservasView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

struct ReservasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var viewModel: ReservasViewModel
    @State private var showingQRScanner = false
    var selectedTab: Binding<Int>
    
    init(viewModel: ReservasViewModel = ReservasViewModel(), selectedTab: Binding<Int> = .constant(0)) {
        self.viewModel = viewModel
        self.selectedTab = selectedTab
    }
      

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Cargando reservas...")
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Reintentar") {
                            viewModel.fetchReservasActuales()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        NavigationLink(destination: NuevaReservaView(selectedTab: selectedTab)) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Nueva reserva")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(.horizontal)
                    
                } else if viewModel.reservasFiltradas.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No tienes reservas registradas.")
                            .font(.headline)
                        Text("Tus próximas reservaciones aparecerán aquí.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                } else {
                    List {
                        // Sección para la primera reserva (Próxima)
                        Section("Próxima Reserva") {
                            // Usamos el primer elemento con binding
                            ReservaListView(
                                vm: $viewModel,
                                reserva: $viewModel.reservasFiltradas[0],
                                esPrimera: true
                            )
                        }
                        
                        // Sección para las siguientes reservas
                        if viewModel.reservasFiltradas.count > 1 {
                            Section("Siguientes Reservas") {
                                // Usamos índices para poder pasar el Binding correctamente
                                ForEach(1..<viewModel.reservasFiltradas.count, id: \.self) { index in
                                    ReservaListView(
                                        vm: $viewModel,
                                        reserva: $viewModel.reservasFiltradas[index],
                                        esPrimera: false
                                    )
                                }
                            }
                        }
                    }
                    .listRowSpacing(10)
                    .refreshable {
                        viewModel.fetchReservasActuales()
                    }
                }
            }
            .navigationTitle("Mis Reservas")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: ReservasHistorialView()) {
                        Image(systemName: "clock")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NuevaReservaView(selectedTab: selectedTab)) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button (action: { showingQRScanner = true } ) {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
            .sheet(isPresented: $showingQRScanner) {
                CameraView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchReservasActuales()
            }
            .onChange(of: sessionManager.profile) {
                if sessionManager.profile != nil {
                    viewModel.fetchReservasActuales()
                }
            }
        }
    }
}

private let fechaHoraFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "es_MX")
    f.dateStyle = .short
    f.timeStyle = .short
    return f
}()

#Preview {
    let mockSessionManager: SessionManager = {
        let manager = SessionManager()
        manager.login(accessToken: "fake_token", refreshToken: nil, expiresAt: Date().addingTimeInterval(3600))
        return manager
    }()
    
    let mockViewModel: ReservasViewModel = {
        let vm = ReservasViewModel()
        vm.reservasFiltradas = [
            Reserva(
                id: 1,
                estudianteId: 123,
                salaUbicacion: "Planta Alta" ,
                salaNumero: 2,
                fechaInicio: Date(),
                fechaFin: Date().addingTimeInterval(3600),
                horaInicio: DateComponents(hour: 7, minute: 0),
                horaFin: DateComponents(hour: 8, minute: 0),
                numPersonas: 4,
                status: .reservada
            )
        ]
        return vm
    }()
    
    ReservasView(viewModel: mockViewModel)
        .environmentObject(mockSessionManager)
}
