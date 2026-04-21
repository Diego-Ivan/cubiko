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
        NavigationStack {
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
                // Aquí pasarías al siguiente paso, usando tus modelos de Cubiculo
                Text("Buscando cubículos tipo: \(viewModel.tipoSeleccionado?.rawValue ?? "")")
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
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.puedeContinuar)
        .opacity(viewModel.puedeContinuar ? 1.0 : 0.4)
        .padding(24)
    }
}

#Preview {
    NuevaReservaView()
}
