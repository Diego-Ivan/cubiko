//
//  RoomRowView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct RoomRowView: View {

    let cubiculo: Cubiculo
    let isSelected: Bool
    let onTap: () -> Void

    // Capacidad según tipo
    private var capacidad: Int {
        switch cubiculo.tipo.lowercased() {
        case "individual": return 1
        case "dual":       return 2
        default:           return 6  // grupal
        }
    }

    private var iconoTipo: String {
        switch cubiculo.tipo.lowercased() {
        case "individual": return "person.fill"
        case "dual":       return "person.2.fill"
        default:           return "person.3.fill"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {

                // Radio button
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.primaryCubiko : Color(.systemGray3),
                            lineWidth: 2
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.primaryCubiko)
                            .frame(width: 12, height: 12)
                    }
                }

                // Ícono tipo
                Image(systemName: iconoTipo)
                    .font(.system(size: 16))
                    .foregroundColor(isSelected ? Color.primaryCubiko : .secondary)
                    .frame(width: 28)

                // Info principal
                VStack(alignment: .leading, spacing: 3) {
                    Text(cubiculo.nombre)
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        // Badge tipo
                        Text(cubiculo.tipo)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(isSelected ? Color.primaryCubiko.opacity(0.12) : Color(.systemGray5))
                            .foregroundColor(isSelected ? Color.primaryCubiko : .secondary)
                            .clipShape(Capsule())

                        // Capacidad
                        Label("\(capacidad) persona\(capacidad == 1 ? "" : "s")", systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Piso
                Text("P\(cubiculo.piso)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(isSelected ? Color.primaryCubiko : .secondary)
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
