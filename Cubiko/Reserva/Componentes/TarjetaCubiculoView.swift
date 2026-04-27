//
//  TarjetaCubiculoView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/25/26.
//
import SwiftUI

struct TarjetaCubiculoView: View {
    let sala: SalaDisponible

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sala \(sala.numero)")
                    .font(.headline)
                Text("\(sala.minPersonas) - \(sala.maxPersonas) personas").font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }
}



struct TarjetaAlternativaView: View {
    let bloque: BloqueHorario
    let onSeleccionar: (BloqueHorario) -> Void

    var body: some View {
        HStack {
            Image(systemName: "clock").foregroundColor(.primaryCubiko).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(bloque.horaInicio.formateadaHora()) – \(bloque.horaFin.formateadaHora())")
                    .font(.subheadline.weight(.semibold))
//                Text("\(bloque.salas.count) cubículo(s) libre(s)")
//                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button("Seleccionar") { onSeleccionar(bloque) }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primaryCubiko)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
