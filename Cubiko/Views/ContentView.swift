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
            BuscadorView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }

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

#Preview{
    ContentView()
}
