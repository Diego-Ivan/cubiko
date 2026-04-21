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

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {

                // Radio button
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.teal : Color(.systemGray3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 14, height: 14)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(cubiculo.nombre)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text(cubiculo.tipo)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
