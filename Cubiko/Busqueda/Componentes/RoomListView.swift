//
//  RoomListView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct RoomListView: View {

    let cubiculos: [Cubiculo]
    @Binding var selectedCubiculo: Cubiculo?
    @Binding var searchText: String

    @State private var pisoSeleccionado: Int? = nil
    private let pisos = [1, 2, 3]

    var cubiculosFiltradosPorPiso: [Cubiculo] {
        guard let piso = pisoSeleccionado else { return cubiculos }
        return cubiculos.filter { $0.piso == piso }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Barra de búsqueda
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
                TextField("Busca por número o apodo...", text: $searchText)
                    .autocorrectionDisabled()
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 10)

            // Filtro de pisos
            HStack(spacing: 8) {
                // "Todos" pill
                PisoChip(label: "Todos", isSelected: pisoSeleccionado == nil) {
                    pisoSeleccionado = nil
                }
                ForEach(pisos, id: \.self) { piso in
                    PisoChip(label: "Piso \(piso)", isSelected: pisoSeleccionado == piso) {
                        pisoSeleccionado = pisoSeleccionado == piso ? nil : piso
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            Divider()

            // Lista
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(cubiculosFiltradosPorPiso) { cubiculo in
                        RoomRowView(
                            cubiculo: cubiculo,
                            isSelected: selectedCubiculo?.id == cubiculo.id,
                            onTap: { selectedCubiculo = cubiculo }
                        )
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
    }
}

// MARK: - Chip de piso

private struct PisoChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.primaryCubiko : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}
