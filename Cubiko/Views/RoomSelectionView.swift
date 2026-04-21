//
//  RoomSelectionView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct RoomSelectionView: View {

    // ── Datos que vienen de BuscadorView ──────────────
    let inicio: Date
    let fin: Date

    // ── Estado interno ─────────────────────────────────
    @StateObject private var viewModel = RoomSelectionViewModel()
    @State private var searchText = ""
    @State private var goToConfirmation = false

    // ── Cubículos filtrados por búsqueda ───────────────
    var cubiculosFiltrados: [Cubiculo] {
        guard !searchText.isEmpty else { return viewModel.cubiculos }
        return viewModel.cubiculos.filter {
            $0.nombre.localizedCaseInsensitiveContains(searchText) ||
            $0.tipo.localizedCaseInsensitiveContains(searchText)
        }
    }

    // ── Body ───────────────────────────────────────────
    var body: some View {
        VStack(spacing: 0) {

            // Pieza 1: Mapa
            LibraryMapView(selectedCubiculo: $viewModel.selectedCubiculo)
                .frame(height: 280)

            // Drag indicator estilo bottom sheet
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.vertical, 8)

            // Pieza 2: Lista con búsqueda
            RoomListView(
                cubiculos: cubiculosFiltrados,
                selectedCubiculo: $viewModel.selectedCubiculo,
                searchText: $searchText
            )

            Spacer()

            // Pieza 3: Botón confirmar
            Button {
                goToConfirmation = true
            } label: {
                Text("Confirmar selección")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        viewModel.selectedCubiculo == nil
                            ? Color.cubikoAzulOscuro.opacity(0.4)
                            : Color.cubikoAzulOscuro
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(viewModel.selectedCubiculo == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Salas individuales")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.cargarCubiculos()
        }
        .navigationDestination(isPresented: $goToConfirmation) {
            if let cubiculo = viewModel.selectedCubiculo {
                BookingConfirmationView(
                    cubiculo: cubiculo,
                    inicio: inicio,
                    fin: fin
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RoomSelectionView(
            inicio: Date(),
            fin: Date().addingTimeInterval(3600)
        )
    }
}
