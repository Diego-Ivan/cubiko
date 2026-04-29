//
//  CompartirReservaView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/29/26.
//

import SwiftUI

struct CompartirReservaView: View {
    let reserva: Reserva
    
    var body: some View {
        VStack {
            
            VistaQRView(reservaId: reserva.id)
            
            Button(action: { }) {
                Text("Buscar personas")
            }
            .buttonStyle(PrimaryButtonStyle())
            

            
        }
        .padding()
        .navigationTitle("Añadir personas a reserva")
        .navigationBarTitleDisplayMode(.inline)
    }
}
