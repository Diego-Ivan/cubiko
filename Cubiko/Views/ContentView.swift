//
//  ContentView.swift
//  Cubiko
//
//  Created by Rafael on 06/04/26.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            ReservaTabView()
                .tabItem {
                    Label("Reserva", systemImage: "calendar")
                }
                .tag(0)
            
            
            MultasView()
                .tabItem {
                    Label("Multas", systemImage: selectedTab == 1 ? "creditcard.fill": "creditcard")
                        .environment(\.symbolVariants, .none) // Prevents automatic iOS filling
                }
                .tag(1)

            
            MaterialesView()
                .tabItem {
                    Label("Materiales", systemImage:
                    selectedTab == 2 ? "backpack.fill": "backpack")
                        .environment(\.symbolVariants, .none) // Prevents automatic iOS filling
                }
                .tag(2)

            ConfiguracionView()
                .tabItem {
                    Label("Configuración", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

#Preview{
    ContentView()
}
