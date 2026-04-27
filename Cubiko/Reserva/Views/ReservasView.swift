//
//  ReservasView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

struct ReservasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State var viewModel: ReservasViewModel
    
    init(viewModel: ReservasViewModel = ReservasViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Cargando reservas...")
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                        Text(error).multilineTextAlignment(.center)
                    }
                    .padding()
                } else if viewModel.reservasFiltradas.isEmpty {
                    
                    Text("No tienes reservas registradas.")
                        .foregroundColor(.secondary)
                        .padding()
                    
                    NavigationLink(destination: NuevaReservaView()) {
                        Text("Nueva reserva")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    
                    
                } else {
                    List {
                        Section("Próxima Reserva") {
                            
                            ReservaListView(reserva: viewModel.reservasFiltradas.first!, esPrimera: true)
                        }
                        
                        if !viewModel.reservasFiltradas[1...].isEmpty {
                            Section("Siguientes Reservas") {
                                
                                
                                ForEach(viewModel.reservasFiltradas[1...], id: \.id) { reserva in
                                    
                                    ReservaListView(reserva: reserva, esPrimera: false)
                                    
                                }
                            }
                        }
                    }
                    .listRowSpacing(10)
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
                    NavigationLink(destination: NuevaReservaView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.fetchReservasActuales(token: sessionManager.profile?.accessToken)
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
        let perfilPrueba = UserProfile(accessToken: "fake_token", refreshToken: nil, expiresAt: Date().addingTimeInterval(3600))
        manager.updateProfile(perfilPrueba)
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
                status: .activa
            )
        ]
        return vm
    }()
    
    ReservasView(viewModel: mockViewModel)
        .environmentObject(mockSessionManager)
}
