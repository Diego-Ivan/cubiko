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

    var body: some View {
        VStack(spacing: 0) {

            // Barra de búsqueda
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))

                TextField("Busca el número o \"esquina\"...", text: $searchText)
                    .autocorrectionDisabled()
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            // Lista de cubículos
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(cubiculos) { cubiculo in
                        RoomRowView(
                            cubiculo: cubiculo,
                            isSelected: selectedCubiculo?.id == cubiculo.id,
                            onTap: {
                                selectedCubiculo = cubiculo
                            }
                        )
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
        }
    }
}
