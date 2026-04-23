//
//  TipoCubiculoCard.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct TipoCubiculoCard: View {
    let tipo: TipoCubiculo
    let disponibles: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTap()
        }) {
            VStack(spacing: 10) {
                // Pill principal
                Text(tipo.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(isSelected ? Color.primaryCubiko : Color.secondaryCubiko)
                    .clipShape(Capsule())
                    .shadow(
                        color: (isSelected ? Color.primaryCubiko : Color.secondaryCubiko).opacity(0.35),
                        radius: 8, y: 4
                    )
                    .scaleEffect(isSelected ? 1.02 : 1.0)

                // Contador debajo, fuera de la pill
                Text("Salas disponibles: \(disponibles)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
