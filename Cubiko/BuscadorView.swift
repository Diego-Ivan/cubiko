//
//  BuscadorView.swift
//  Cubiko
//
//  Created by Rafael on 07/04/26.
//

import SwiftUI

struct BuscadorView: View {
    
    @State private var fecha = Date()
    @State private var horaEntrada = Date()
    @State private var horaSalida = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                DatePicker("Fecha", selection: $fecha, displayedComponents: .date)
                    .padding(.horizontal)
                
                DatePicker("Hora de entrada", selection: $horaEntrada, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)
                
                DatePicker("Hora de salida", selection: $horaSalida, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)
                
                Button("Buscar") {
                    // TODO: conectar con viewmodel
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Nueva reserva")
        }
    }
}

#Preview {
    BuscadorView()
}
