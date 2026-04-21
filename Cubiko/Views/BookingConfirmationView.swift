//
//  BookingConfirmationView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import SwiftUI

struct BookingConfirmationView: View {

    let cubiculo: Cubiculo
    let inicio: Date
    let fin: Date

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // ── Ícono de éxito ──────────────────────────
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.cubikoAzul.opacity(0.12))
                            .frame(width: 88, height: 88)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 52))
                            .foregroundColor(.cubikoAzul)
                    }

                    Text("¡Reserva confirmada!")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)

                    Text("Tu cubículo está listo para el horario seleccionado.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 16)

                // ── Tarjeta de detalles ─────────────────────
                VStack(spacing: 0) {

                    FilaDetalle(
                        icono: "door.left.hand.open",
                        label: "Cubículo",
                        valor: cubiculo.nombre
                    )

                    Divider().padding(.leading, 48)

                    FilaDetalle(
                        icono: "tag",
                        label: "Tipo",
                        valor: cubiculo.tipo
                    )

                    Divider().padding(.leading, 48)

                    FilaDetalle(
                        icono: "calendar",
                        label: "Fecha",
                        valor: inicio.formateadaFecha()
                    )

                    Divider().padding(.leading, 48)

                    FilaDetalle(
                        icono: "clock",
                        label: "Entrada",
                        valor: inicio.formateadaHora()
                    )

                    Divider().padding(.leading, 48)

                    FilaDetalle(
                        icono: "clock.badge.checkmark",
                        label: "Salida",
                        valor: fin.formateadaHora()
                    )
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
                .padding(.horizontal)

                // ── Botones ─────────────────────────────────
                VStack(spacing: 12) {
                    Button {
                        // Aquí irá la acción real cuando conectes el VM
                        dismiss()
                    } label: {
                        Text("Ir al inicio")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.cubikoAzulOscuro)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Ver mis reservas")
                            .font(.headline)
                            .foregroundColor(.cubikoAzulOscuro)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.cubikoAzulOscuro.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Confirmación")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Fila de detalle

private struct FilaDetalle: View {
    let icono: String
    let label: String
    let valor: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .foregroundColor(.cubikoAzul)
                .frame(width: 24)

            Text(label)
                .foregroundColor(.secondary)
                .font(.subheadline)

            Spacer()

            Text(valor)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BookingConfirmationView(
            cubiculo: Cubiculo(id: 1, nombre: "Sala #1", tipo: "Individual"),
            inicio: Date(),
            fin: Date().addingTimeInterval(3600)
        )
    }
}
