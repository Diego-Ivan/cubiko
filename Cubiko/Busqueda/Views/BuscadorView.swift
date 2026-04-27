//
//  BuscadorView.swift
//  Cubiko
//
//  Created by Rafael on 07/04/26.
//

import SwiftUI

struct BuscadorView: View {

    // onReservar se pasa al crear el vm, no en onAppear
    private let onReservar: ((SalaDisponible, Date, Date) -> Void)?
    var capacidadMinimal: Int?

    @StateObject private var vm: BuscadorViewModel

    @State private var mostrarFecha   = false
    @State private var mostrarEntrada = false
    @State private var mostrarSalida  = false
    
    @State private var terminaSiguienteDia = false
    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""
    
    init(capacidadMinima: Int, onReservar: ((SalaDisponible, Date, Date) -> Void)? = nil) {
            self.onReservar = onReservar
            
            // Creamos el ViewModel temporalmente
            let nuevoVM = BuscadorViewModel.make(onReservar: onReservar)
            // Le inyectamos la capacidad
            nuevoVM.capacidadMinima = capacidadMinima
            // Lo asignamos al StateObject
            _vm = StateObject(wrappedValue: nuevoVM)
        }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                camposBusqueda
                botonBuscar
                resultados
                Spacer(minLength: 40)
            }
            .padding(16)

        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Nueva Reserva")
        .animation(.easeInOut(duration: 0.25), value: mostrarFecha)
        .animation(.easeInOut(duration: 0.25), value: mostrarEntrada)
        .animation(.easeInOut(duration: 0.25), value: mostrarSalida)
        .overlay(alignment: .bottom) {
            Button(action: {
                vm.confirmarReserva()
            }) {
                Text("Crear reserva")
            }
            .padding(.horizontal)
            .buttonStyle(PrimaryButtonStyle())
            .disabled(vm.salaSeleccionada == nil)
            .padding(16)
            .shadow(radius: 15)
        }
    }

    // MARK: - Campos

    private var camposBusqueda: some View {
        VStack(spacing: 0) {
            
            FilaCampo(label: "Fecha", valor: vm.fechaSeleccionada.formateadaFecha()) {
                mostrarFecha.toggle(); mostrarEntrada = false; mostrarSalida = false
            }
            if mostrarFecha {
                DatePicker("",
                           selection: $vm.fechaSeleccionada,
                           in: Date()...,
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            Divider().padding(.leading)

            FilaCampo(label: "Hora de entrada", valor: vm.horaEntrada.formateadaHora()) {
                mostrarEntrada.toggle(); mostrarFecha = false; mostrarSalida = false
            }
            if mostrarEntrada {
                DatePicker("",
                           selection: $vm.horaEntrada,
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }

            Divider().padding(.leading)
            
            Toggle("Salida el día siguiente", isOn: $terminaSiguienteDia)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .tint(.primaryCubiko)

            FilaCampo(label: "Hora de salida", valor: vm.horaSalida.formateadaHora()) {
                mostrarSalida.toggle(); mostrarFecha = false; mostrarEntrada = false
            }
            if mostrarSalida {
                DatePicker("",
                           selection: $vm.horaSalida,
                           displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Botón buscar

    private var botonBuscar: some View {
        Button(action: validarYBuscar) {
            Text("Buscar disponibilidad")
        }
        .padding(.horizontal)
        .buttonStyle(SecondaryButtonStyle())

        .alert("Horario inválido", isPresented: $mostrarAlerta) {
                Button("Entendido", role: .cancel) { }
            } message: {
                Text(mensajeAlerta)
            }
    }

    // MARK: - Resultados

    @ViewBuilder
    private var resultados: some View {
        switch vm.estado {
        case .inicial:
            EmptyView()

        case .disponible(let salas):
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("\(salas.count) cubículo(s) disponibles").font(.headline)
                }
                .padding(.horizontal)

                if let sala = vm.salaSeleccionada {
                    LibraryMapView(selectedCubiculo: $vm.salaSeleccionada)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    
                    TarjetaCubiculoView(sala: sala)
                }

                NavigationLink {
                    RoomSelectionView(salas: salas, selectedSala: $vm.salaSeleccionada)
                } label: {
                    HStack {
                        Text("Elegir otra sala")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.primaryCubiko.opacity(0.15))
                    .foregroundColor(.primaryCubiko)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }

        case .sinDisponibilidad(let alternativas):
            SeccionSinDisponibilidadView(alternativas: alternativas) { bloque in
                vm.seleccionarBloque(bloque)
            }
        }
    }
    
    private func validarYBuscar() {
        let calendar = Calendar.current
        
        // 1. Construct Full Dates
        let inicio = vm.combinar(fecha: vm.fechaSeleccionada, hora: vm.horaEntrada)
        var fin = vm.combinar(fecha: vm.fechaSeleccionada, hora: vm.horaSalida)
        
        if terminaSiguienteDia {
            fin = calendar.date(byAdding: .day, value: 1, to: fin)!
            vm.fechaFin = fin
        }

        // 2. Logic Validations
        let duracionMinima: TimeInterval = 30 * 60 // 2 hours 30 mins in seconds
        
        if fin <= inicio {
            mensajeAlerta = "La hora de salida debe ser posterior a la de entrada."
            mostrarAlerta = true
        } else if fin.timeIntervalSince(inicio) < duracionMinima {
            mensajeAlerta = "La reserva mínima es de \(duracionMinima / 60) minutos."
            mostrarAlerta = true
        } else if calendar.isDateInToday(vm.fechaSeleccionada) && inicio < Date() {
            mensajeAlerta = "No puedes reservar una hora que ya pasó."
            mostrarAlerta = true
        } else {
            // All good! Pass the corrected dates to the VM
            vm.buscar()
        }
    }
}

// MARK: - Subviews

struct FilaCampo: View {
    let label: String
    let valor: String
    let accion: () -> Void

    var body: some View {
        Button(action: accion) {
            HStack {
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
                Text(valor)
                    .foregroundColor(Color.primaryCubiko)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            .padding(.vertical, 14)
        }
    }
}



struct SeccionSinDisponibilidadView: View {
    let alternativas: [BloqueHorario]
    let onSeleccionar: (BloqueHorario) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sin disponibilidad").font(.headline)
                    Text("No hay cubículos libres en ese horario.")
                        .font(.subheadline).foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            .padding(.horizontal)

            if !alternativas.isEmpty {
                Text("Horarios cercanos disponibles")
                    .font(.headline)
                    .padding(.horizontal)

                ForEach(alternativas) { bloque in
                    TarjetaAlternativaView(bloque: bloque, onSeleccionar: onSeleccionar)
                }
            }
        }
    }
}

// MARK: - Date Formatters

extension Date {
    func formateadaFecha() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "MMMM d, yyyy"
        return f.string(from: self).capitalized
    }

    func formateadaHora() -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "es_MX")
        f.dateFormat = "h:mm a"
        return f.string(from: self)
    }
}

// MARK: - Preview

#Preview {
    BuscadorView(capacidadMinima: 1)
}
