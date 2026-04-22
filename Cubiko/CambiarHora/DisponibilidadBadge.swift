//
//  DisponibilidadBadge.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import SwiftUI

struct DisponibilidadBadge: View {

    let estado: DisponibilidadEstado

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icono)
                .font(.caption.weight(.semibold))
            Text(texto)
                .font(.subheadline.weight(.medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }

    private var icono: String {
        switch estado {
        case .libre:    return "checkmark.circle"
        case .conflicto: return "xmark.circle"
        case .invalido: return "exclamationmark.triangle"
        case .validando: return "arrow.2.circlepath.circle"
        }
    }

    private var texto: String {
        switch estado {
        case .libre:    return "Libre"
        case .conflicto: return "Conflicto"
        case .invalido: return "Inválido"
        case .validando: return "Validando..."
        }
    }

    private var color: Color {
        switch estado {
        case .libre:    return .green
        case .conflicto: return .red
        case .invalido: return .orange
        case .validando: return .gray
        }
    }
}
