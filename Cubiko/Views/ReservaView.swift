//
//  ReservaView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/15/26.
//

import SwiftUI

struct ReservaView: View {
    let reserva: Reserva
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .center, spacing: 20) {
                    
                    // MARK: - Reservation Card
                    ReservaCard(reserva: reserva)
                        .padding(.horizontal)
                    
                    TiempoRestanteView(fechaFin: Date().addingTimeInterval(3 * 60))
                    
                    // MARK: - Help and Support
                    HStack {
                        Text("Ayuda y soporte")
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding() // Padding inside the HStack
                    .contentShape(Rectangle()) // Makes the entire row tappable
                    .onTapGesture {
                        print("Ayuda y soporte tapped")
                    }
                    .padding(.horizontal) // Padding from the sides of the screen
                    
                    // MARK: - Action Buttons
                    VStack(spacing: 10) {
                        Button(action: {
                            print("Cambiar hora de reserva tapped")
                        }) {
                            Text("Cambiar hora de reserva")
                        }
                        .padding(.horizontal)
                        .buttonStyle(TertiaryButtonStyle())
                        
                        Button(action: {
                            print("Cancelar reserva tapped")
                        }) {
                            Text("Cancelar reserva")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.red.opacity(0.15)) // Light red background
                                )
                        }
                        .padding(.horizontal)
                        
                    }
                    .padding()
                    
                    Spacer() // Pushes content up, leaving space for the bottom nav bar
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Ensure VStack takes full width and aligns top leading
            }
            .navigationTitle("Mi Reserva")
        }
    }
}

#Preview {
    ReservaView(reserva: Reserva(id: UUID(), cubiculo: Cubiculo(id: 1, nombre: "Sala 1", tipo: "Individual"), inicio: Date(), fin: Date().addingTimeInterval(1 * 60 * 60)))

}
