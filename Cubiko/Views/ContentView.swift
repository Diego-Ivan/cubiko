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
            PruebaNotificacionesView()
                .tabItem {
                    Label("Reserva", systemImage: "calendar")
                }

            ConfiguracionView()
                .tabItem {
                    Label("Configuración", systemImage: "gearshape")
                }
        }
    }
}
