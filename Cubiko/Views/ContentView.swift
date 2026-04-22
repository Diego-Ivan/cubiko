//
//  ContentView.swift
//  Cubiko
//
//  Created by Rafael on 06/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
                ReservaView()
                .tabItem {
                    Label("Reserva", systemImage: "calendar")
                }
            ConfiguracionView()
                .tabItem {
                    Label("Configuración", systemImage: "gearshape")
                }
            
            NuevaReservaView()
                .tabItem {
                    Label("Nueva Reserva", systemImage: "plus.square.fill")
                }
        }
    }
}

#Preview{
    ContentView()
}
