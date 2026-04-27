//
//  NuevaReservaView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct NuevaReservaView: View {
    @State private var viewModel = NuevaReservaViewModel()

    var body: some View {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        headerSection
                        
                        VStack(spacing: 16) {
                            ForEach(TipoCubiculo.allCases, id: \.self) { tipo in
                                TipoCubiculoCard(
                                    tipo: tipo,
                                    disponibles: viewModel.disponibilidad[tipo] ?? 0,
                                    isSelected: viewModel.tipoSeleccionado == tipo
                                ) {
                                    viewModel.seleccionar(tipo)
                                }
                            }
                        }
                    }
                    .padding(24)
                }

                confirmButton
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $viewModel.navegarASiguiente) {
                if let tipo = viewModel.tipoSeleccionado {
                    // Le pasamos el tipo al Buscador para que filtre por capacidad
                    BuscadorView(
                        capacidadMinima: tipo.capacidad,
                        onReservar: { sala, inicio, fin in
                            viewModel.crearReserva(sala: sala, inicio: inicio, fin: fin)
                        }
                    )
                }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nueva Reserva")
                .font(.system(.largeTitle, design: .rounded)).bold()
            Text("¿Qué tipo de sala buscas?")
                .foregroundColor(.secondary)
        }
    }

    private var confirmButton: some View {
        Button { viewModel.navegarASiguiente = true } label: {
            Text("Continuar")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.puedeContinuar ? Color.accentColor : Color.gray.opacity(0.3))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.puedeContinuar)
        .padding(24)
    }
    
//    func crearReserva(sala: SalaDisponible, inicio: Date, fin: Date) {
//        // 1. Aquí irá la lógica para llamar a tu backend (POST)
//        print("Buscando crear reserva en sala \(sala.numero) a las \(inicio)")
//        
//        self.navegarASiguiente = false
//        self.tipoSeleccionado = nil
//    }
}

#Preview {
    NuevaReservaView()
}
