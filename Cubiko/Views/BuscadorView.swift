//
//  BuscadorView.swift
//  Cubiko
//
//  Created by Rafael on 07/04/26.
//

import SwiftUI

struct BuscadorView: View {

    @StateObject private var vm = BuscadorViewModel.makeDefault()

    @State private var mostrarFecha   = false
    @State private var mostrarEntrada = false
    @State private var mostrarSalida  = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    camposBusqueda
                    botonBuscar
                    resultados
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Buscar disponibilidad")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut(duration: 0.25), value: mostrarFecha)
            .animation(.easeInOut(duration: 0.25), value: mostrarEntrada)
            .animation(.easeInOut(duration: 0.25), value: mostrarSalida)
        }
    }

    // MARK: - Campos

    private var camposBusqueda: some View {
        VStack(spacing: 0) {
            // Fecha
            FilaCampo(label: "Fecha", valor: vm.fechaSeleccionada.formateadaFecha()) {
                mostrarFecha.toggle()
                mostrarEntrada = false
                mostrarSalida  = false
            }
            if mostrarFecha {
                DatePicker("", selection: $vm.fechaSeleccionada, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .transition(.opacity)
            }

            Divider().padding(.leading)

            // Hora entrada
            FilaCampo(label: "Hora de entrada", valor: vm.horaEntrada.formateadaHora()) {
                mostrarEntrada.toggle()
                mostrarFecha  = false
                mostrarSalida = false
            }
            if mostrarEntrada {
                DatePicker("", selection: $vm.horaEntrada, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .transition(.opacity)
            }

            Divider().padding(.leading)

            // Hora salida
            FilaCampo(label: "Hora de salida", valor: vm.horaSalida.formateadaHora()) {
                mostrarSalida.toggle()
                mostrarFecha   = false
                mostrarEntrada = false
            }
            if mostrarSalida {
                DatePicker("", selection: $vm.horaSalida, displayedComponents: .hourAndMinute)
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

    // MARK: - Botón

    private var botonBuscar: some View {
        Button(action: vm.buscar) {
            Text("Buscar disponibilidad")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.cubikoAzulOscuro)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal)
    }

    // MARK: - Resultados

    @ViewBuilder
    private var resultados: some View {
        switch vm.estado {
        case .inicial:
            EmptyView()
        case .disponible(let cubiculos):
            SeccionDisponibleView(cubiculos: cubiculos)
        case .sinDisponibilidad(let alternativas):
            SeccionSinDisponibilidadView(alternativas: alternativas) { bloque in
                vm.seleccionarBloque(bloque)
            }
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
                    .foregroundColor(.cubikoAzulOscuro)
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

struct SeccionDisponibleView: View {
    let cubiculos: [Cubiculo]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                Text("\(cubiculos.count) cubículo(s) disponibles").font(.headline)
            }
            .padding(.horizontal)

            ForEach(cubiculos) { cubiculo in
                TarjetaCubiculoView(cubiculo: cubiculo)
            }
        }
    }
}

struct TarjetaCubiculoView: View {
    let cubiculo: Cubiculo

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(cubiculo.nombre).font(.headline)
                Text(cubiculo.tipo).font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(.cubikoAzul)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct SeccionSinDisponibilidadView: View {
    let alternativas: [BloqueHorario]
    let onSeleccionar: (BloqueHorario) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Banner sin disponibilidad
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

struct TarjetaAlternativaView: View {
    let bloque: BloqueHorario
    let onSeleccionar: (BloqueHorario) -> Void

    var body: some View {
        HStack {
            Image(systemName: "clock").foregroundColor(.cubikoAzul).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(bloque.horaInicio.formateadaHora()) – \(bloque.horaFin.formateadaHora())")
                    .font(.subheadline.weight(.semibold))
                Text("\(bloque.cubiculosDisponibles) cubículo(s) libre(s)")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button("Seleccionar") { onSeleccionar(bloque) }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.cubikoAzul)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Color Palette

extension Color {
    static let cubikoAzul       = Color(red: 0.42, green: 0.65, blue: 0.75)
    static let cubikoAzulOscuro = Color(red: 0.18, green: 0.42, blue: 0.55)
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
    BuscadorView()
}
