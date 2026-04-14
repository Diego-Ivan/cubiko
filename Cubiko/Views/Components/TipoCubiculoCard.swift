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
            HStack(spacing: 20) {
                // Icono
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected ? .white.opacity(0.2) : Color.accentColor.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: tipo.icono)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(isSelected ? .white : .accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(tipo.rawValue).font(.headline).foregroundColor(isSelected ? .white : .primary)
                    Text(tipo.descripcion).font(.subheadline).foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                Spacer()
                
                // Contador
                VStack(alignment: .trailing) {
                    Text("\(disponibles)").font(.title2).bold()
                    Text("libres").font(.caption2).textCase(.uppercase)
                }
                .foregroundColor(isSelected ? .white : .accentColor)
            }
            .padding(20)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: isSelected ? .accentColor.opacity(0.3) : .black.opacity(0.05), radius: 10, y: 5)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
