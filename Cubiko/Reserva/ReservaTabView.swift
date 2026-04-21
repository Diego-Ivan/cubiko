//
//  ReservaTabView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

struct ReservaTabView: View {
    @State var tieneReserva: Bool = true
    
    var body: some View {
        ZStack {
            if tieneReserva {
                ReservaView(reserva: Reserva(id: UUID(), cubiculo: Cubiculo(id: 1, nombre: "Sala 1", tipo: "Individual"), inicio: Date(), fin: Date().addingTimeInterval(1 * 60 * 60)))
            } else {
                NuevaReservaView()
            }
        }
    }
}

#Preview {
    ReservaTabView()
}
