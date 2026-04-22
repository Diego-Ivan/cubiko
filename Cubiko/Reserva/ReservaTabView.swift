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
                ReservasView()
            } else {
                NuevaReservaView()
            }
        }
    }
}

#Preview {
    ReservaTabView()
}
