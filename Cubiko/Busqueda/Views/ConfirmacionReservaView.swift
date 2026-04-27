//
//  ConfirmacionReservaView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/25/26.
//


import SwiftUI

struct ConfirmacionReservaView: View {
    @Environment(\.dismiss) var dismiss

    let sala: SalaDisponible
    let fechaInicio: Date
    let fechaFin: Date
    
    // This environment variable allows us to dismiss the current view
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Header
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .symbolEffect(.bounce, value: 1) // iOS 17+ animation
                
                Text("¡Reserva Confirmada!")
                    .font(.title.bold())
                
                Text("Tu cubículo ha sido apartado exitosamente.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            // Summary Card
            VStack(spacing: 0) {
                ResumenFila(icon: "door.left.hand.closed", label: "Cúbiculo", value: "Sala \(sala.numero)")
                Divider().padding(.leading, 44)
                ResumenFila(icon: "calendar", label: "Fecha", value: fechaInicio.formateadaFecha())
                Divider().padding(.leading, 44)
                ResumenFila(icon: "clock", label: "Horario", value: "\(fechaInicio.formateadaHora()) - \(fechaFin.formateadaHora())")
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            
            Spacer()

            // Return Button
            Button(action: {
                // Return to the main screen
                dismiss()
            }) {
                Text("Volver al inicio")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue) // Replace with Color.primaryCubiko
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationBarBackButtonHidden(true) // Prevent going back to the search results
        .background(Color(.systemGroupedBackground))
    }
}

// Helper view for the summary rows
struct ResumenFila: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body.weight(.medium))
            }
            Spacer()
        }
        .padding()
    }
}
