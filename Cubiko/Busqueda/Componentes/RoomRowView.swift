//
//  RoomRowView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct RoomRowView: View {

    let sala: SalaDisponible
    let isSelected: Bool
    let onTap: () -> Void

    private var iconoTipo: String {
        switch sala.maxPersonas {
        case 1:       return "person.fill"
        case 2:       return "person.2.fill"
        default:      return "person.3.fill"
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
                    Text("Sala #\(sala.numero)")
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        // Badge tipo
//                        Text(sala.tipo)
//                            .font(.caption.weight(.medium))
//                            .padding(.horizontal, 7)
//                            .padding(.vertical, 2)
//                            .background(isSelected ? Color.primaryCubiko.opacity(0.12) : Color(.systemGray5))
//                            .foregroundColor(isSelected ? Color.primaryCubiko : .secondary)
//                            .clipShape(Capsule())

                        // Capacidad
                        Label("\(sala.maxPersonas) persona\(sala.maxPersonas == 1 ? "" : "s")", systemImage: "person.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Piso
                Text("\(sala.ubicacion)")
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


#Preview {
    RoomRowView(sala: SalaDisponible(numero: 1, ubicacion: "Piso 1", maxPersonas: 1, minPersonas: 1), isSelected: true, onTap: {})
}
