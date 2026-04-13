//
//  ConfigurationView.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import SwiftUI

// MARK: - Fila con wheel picker expandible

/// Componente reutilizable: una fila que al tocarla expande un wheel picker de minutos.
/// Úsalo para cualquier otra preferencia de tiempo que necesiten en el futuro.
private struct FilaMinutosPicker: View {

    let titulo: String
    @Binding var minutos: Int
    @Binding var expandida: Bool          // cuál fila está abierta (viene del padre)
    let id: String                         // identificador único de esta fila

    private var estaExpandida: Bool { expandida == true && expandidaID == id }

    // Para que solo una fila esté abierta a la vez, usamos un binding
    // al ID de la fila expandida actualmente.
    @Binding var expandidaID: String

    private let opcionesMinutos = Array(stride(from: 5, through: 30, by: 1))  // 5, 10, 15 ... 60

    var body: some View {
        // Fila principal (tappable)
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                expandidaID = (expandidaID == id) ? "" : id
            }
        } label: {
            HStack {
                Text(titulo)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(minutos) min antes")
                    .foregroundStyle(expandidaID == id ? .blue : .secondary)
            }
        }

        // Wheel picker — aparece/desaparece con animación
        if expandidaID == id {
            Picker("", selection: $minutos) {
                ForEach(opcionesMinutos, id: \.self) { mins in
                    Text("\(mins) minutos").tag(mins)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            // Sin transition aquí porque List ya anima la inserción de filas
        }
    }
}

// MARK: - Vista principal

struct ConfiguracionView: View {

    @AppStorage("minutosAvisoInicio") private var minutosAvisoInicio: Int = 15
    @AppStorage("minutosAvisoFin")    private var minutosAvisoFin: Int    = 15

    // ID de la fila que está expandida actualmente ("" = ninguna)
    @State private var filaExpandida: String = ""

    var body: some View {
        NavigationView {
            List {

 /*
                // MARK: Mi información
                Section("Mi información") {
                    LabeledContent("Nombre", value: "Nombre Apellido1 Apellido2")
                    LabeledContent("Correo", value: "correo.nombre@udlap.mx")
                    LabeledContent("ID", value: "XXXXXX")
                }
*/
  
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

/*
                // MARK: Ayuda
                Section("Ayuda") {
                    NavigationLink("¿Cómo funciona la app de reservas?") {
                        Text("Próximamente...")
                            .foregroundStyle(.secondary)
                    }
                }
*/
 
                // MARK: Cerrar sesión
                Section {
                    Button(role: .destructive) {
                        // TODO: conectar con lógica de autenticación
                    } label: {
                        Text("Cerrar sesión")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Configuración")
        }
    }
}

#Preview {
    ConfiguracionView()
}
