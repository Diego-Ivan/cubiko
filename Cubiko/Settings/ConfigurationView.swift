//
//  ConfigurationView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import SwiftUI

struct ConfiguracionView: View {
    
    @EnvironmentObject var sessionManager: SessionManager

    @AppStorage("minutosAvisoInicio") private var minutosAvisoInicio: Int = 15
    @AppStorage("minutosAvisoFin")    private var minutosAvisoFin: Int    = 15

    // ID de la fila que está expandida actualmente ("" = ninguna)
    @State private var filaExpandida: String = ""
    
    @State private var mostrarAlerta: Bool = false

    var body: some View {
        NavigationView {
            List {


                // MARK: Mi información
//                Section("Mi información") {
//                    LabeledContent("Nombre", value: "Nombre Apellido1 Apellido2")
//                    LabeledContent("Correo", value: "correo.nombre@udlap.mx")
//                    LabeledContent("ID", value: "XXXXXX")
//                }

  
                // MARK: Notificaciones
                Section("Notificaciones") {
                    FilaMinutosPicker(
                        titulo: "Al iniciar una reserva",
                        minutos: $minutosAvisoInicio,
                        expandida: .constant(true),   // siempre puede expandirse
                        id: "inicio",
                        expandidaID: $filaExpandida
                    )

                    FilaMinutosPicker(
                        titulo: "Al finalizar una reserva",
                        minutos: $minutosAvisoFin,
                        expandida: .constant(true),
                        id: "fin",
                        expandidaID: $filaExpandida
                    )
                }


                // MARK: Ayuda
                Section("Ayuda") {
                    NavigationLink("¿Cómo funciona la app de reservas?") {
                        Text("Próximamente...")
                            .foregroundStyle(.secondary)
                    }
                }

 
                // MARK: Cerrar sesión
                Section {
                    Button(role: .destructive) {
                        mostrarAlerta = true
                    } label: {
                        Text("Cerrar sesión")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Configuración")
            .alert("¿Cerrar sesión?", isPresented: $mostrarAlerta) {
                    Button("Cerrar sesión", role: .destructive) {
                        sessionManager.logout()
                    }
                
                Button("Regresar", role: .cancel) {
                        mostrarAlerta = false
                    }
                } message: {
                    Text("Deberás volver a iniciar sesión para acceder a sus reservas")
                }
        }
    }
}

#Preview {
    ConfiguracionView()
}
