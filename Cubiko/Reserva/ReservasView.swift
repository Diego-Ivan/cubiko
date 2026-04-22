//
//  ReservasView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

struct ReservasView: View {
    @State private var viewModel = ReservasViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Cargando reservas...")
                } else if let error = viewModel.error {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                        Text(error).multilineTextAlignment(.center)
                    }
                    .padding()
                } else if viewModel.reservas.isEmpty {
                    Text("No tienes reservas registradas.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.reservas, id: \.id) { reserva in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(String(reserva.salaNumero))
                                    .font(.headline)
                                Text("Inicio: \(reserva.fechaInicio, formatter: fechaHoraFormatter)")
                                    .font(.subheadline)
                                Text("Fin: \(reserva.fechaFin, formatter: fechaHoraFormatter)")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Mis Reservas")
            .onAppear {
                if viewModel.reservas.isEmpty && !viewModel.isLoading {
                    viewModel.fetchReservas()
                }
            }
        }
    }
}

private let fechaHoraFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "es_MX")
    f.dateStyle = .medium
    f.timeStyle = .short
    return f
}()

#Preview {
    ReservasView()
}
