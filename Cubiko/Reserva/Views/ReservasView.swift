//
//  ReservasView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

struct ReservasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var viewModel = ReservasViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
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
                        Text("Agregar Reserva")
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
            .onAppear {
                viewModel.fetchReservasActuales(token: sessionManager.profile?.accessToken)
            }
            .toolbar {
                NavigationLink(destination: ReservasHistorialView()) {
                    Image(systemName: "clock")
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
    let mockSessionManager = SessionManager()
    let perfilPrueba = UserProfile(accessToken: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidGlwbyI6ImVzdHVkaWFudGUiLCJlbWFpbCI6ImF6dWFueS5taWxhY25AdWRsYXAubXgiLCJpYXQiOjE3NzY4MjMyNDcsImV4cCI6MTc3NjkwOTY0N30.hF7frRzHMEPUdd8jkAp83NAuAIBCwtuv9hX4Q25w4Bo")
        mockSessionManager.updateProfile(perfilPrueba)

    return ReservasView()
            .environmentObject(mockSessionManager)
}
