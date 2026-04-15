//
//  CubikoApp.swift
//  Cubiko
//
//  Created by Rafael on 06/04/26.
//

import SwiftUI

@main
struct CubikoApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    // Solicitar permisos de notificación al arrancar la app
                    await NotificationService.shared.solicitarPermiso()
                }
        }
    }
}
