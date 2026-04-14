//
//  TiempoRestanteView.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

import SwiftUI
import Combine

struct TiempoRestanteView: View {

    let fechaFin: Date

    @State private var tiempoRestante: TimeInterval = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 4) {
            Text(tiempoFormateado)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(colorSegunTiempo)

            Text("restantes")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .onAppear { actualizarTiempo() }
        .onReceive(timer) { _ in actualizarTiempo() }
    }

    // MARK: - Helpers

    private func actualizarTiempo() {
        tiempoRestante = max(fechaFin.timeIntervalSinceNow, 0)
    }

    private var tiempoFormateado: String {
        let horas   = Int(tiempoRestante) / 3600
        let minutos = (Int(tiempoRestante) % 3600) / 60
        let segundos = Int(tiempoRestante) % 60

        if horas > 0 {
            return String(format: "%02d:%02d:%02d", horas, minutos, segundos)
        } else {
            return String(format: "%02d:%02d", minutos, segundos)
        }
    }

    private var colorSegunTiempo: Color {
        if tiempoRestante <= 0        { return .gray   }
        if tiempoRestante <= 5 * 60   { return .red    }  // menos de 5 min
        if tiempoRestante <= 15 * 60  { return .orange }  // menos de 15 min
        return .primary
    }
}

#Preview {
    // Simula una reserva que termina en 12 minutos
    TiempoRestanteView(fechaFin: Date().addingTimeInterval(12 * 60))
}
