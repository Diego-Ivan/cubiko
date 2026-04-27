//
//  LibraryMapView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct LibraryMapView: View {

    @Binding var selectedCubiculo: SalaDisponible?

    var body: some View {
        ZStack {
            Color(.systemGray6)

            VStack(spacing: 8) {
                Image(systemName: "map")
                    .font(.system(size: 36))
                    .foregroundColor(.secondary)
                Text("Mapa de la biblioteca")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        // Cuando tengas el SDK del mapa, reemplazas este ZStack
        // y el Binding ya está listo para recibir taps en los pines
    }
}
