//
//  RoomSelectionView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct RoomSelectionView: View {

    let salas: [SalaDisponible]
    @Binding var selectedSala: SalaDisponible?
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""

    // ── Cubículos filtrados por búsqueda ───────────────
    var salasFiltradas: [SalaDisponible] {
        guard !searchText.isEmpty else { return salas }
        return salas.filter {
            String($0.numero).contains(searchText) ||
            $0.ubicacion.localizedCaseInsensitiveContains(searchText)
        }
    }

    // ── Body ───────────────────────────────────────────
    var body: some View {
        VStack(spacing: 0) {

            // Pieza 1: Mapa
            LibraryMapView(selectedCubiculo: $selectedSala)
                .frame(height: 280)

            // Drag indicator estilo bottom sheet
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.vertical, 8)

            // Pieza 2: Lista con búsqueda
            RoomListView(
                salas: salasFiltradas,
                selectedSala: $selectedSala,
                searchText: $searchText
            )

            Spacer()

            // Pieza 3: Botón confirmar
            Button {
                dismiss()
            } label: {
                Text("Confirmar selección")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(selectedSala == nil)
            .opacity(selectedSala == nil ? 0.4 : 1.0)
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .navigationTitle("Salas individuales")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var dummySala: SalaDisponible? = SalaDisponible(numero: 1, ubicacion: "Piso 1", maxPersonas: 4, minPersonas: 1)
    NavigationStack {
        RoomSelectionView(
            salas: [dummySala!],
            selectedSala: $dummySala
        )
    }
}
