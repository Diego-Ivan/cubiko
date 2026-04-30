//
//  CameraView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/28/26.
//

import SwiftUI
import CodeScanner
internal import AVFoundation



struct CameraView: View {
    @Bindable var viewModel: ReservasViewModel
    
    @State private var isPresentingInvitation = false
    @State private var isPresentingActivation = false
    @State private var isPresentingFinalization = false
    @State private var scannedCode: String?
    @State private var selectedReserva: Reserva?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    
    private let aceptarUseCase = AceptarInvitacionConQrUseCase(repository: RealRoomRepository())
    private let activarUseCase = ActivarReservaUseCase(repository: RealRoomRepository())
    private let finalizarUseCase = FinalizarReservaUseCase(repository: RealRoomRepository())


    var body: some View {
        
        Text("Escanea el código QR")
             
        CodeScannerView(codeTypes: [.qr]) { response in
            if case let .success(result) = response {
                let code = result.string.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Caso 1: Invitación (ID de reserva puro)
                if let _ = Int(code) {
                    scannedCode = code
                    isPresentingInvitation = true
                    return
                }
                
                // Caso 2: Código de Sala (ej: "2;Planta Alta")
                let parts = code.components(separatedBy: ";")
                if parts.count == 2, let roomNum = Int(parts[0]) {
                    let roomUbicacion = parts[1]
                    
                    validarEscaneoDeSala(sala: roomNum, ubicacion: roomUbicacion)
                }
            }
        }
        .alert("Invitación a reserva", isPresented: $isPresentingInvitation) {
            Button("Sí, aceptar invitación", role: .confirm) {
                if let code = scannedCode, let id = Int(code) {
                    aceptarInvitacion(id: id)
                }
            }
            Button("No, rechazar invitación", role: .destructive) {
                dismiss()
            }
        }
        .alert("Activar Reserva", isPresented: $isPresentingActivation) {
            Button("Activar ahora", role: .confirm) {
                if let reserva = selectedReserva {
                    activarReserva(id: reserva.id)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            if let r = selectedReserva {
                Text("¿Deseas activar tu reserva en \(r.salaUbicacion), Sala #\(r.salaNumero)?")
            }
        }
        .alert("Finalizar Reserva", isPresented: $isPresentingFinalization) {
            Button("Terminar ahora", role: .confirm) {
                if let reserva = selectedReserva {
                    finalizarReserva(id: reserva.id)
                }
            }
            Button("Seguir en la sala", role: .cancel) {}
        } message: {
            if let r = selectedReserva {
                Text("¿Deseas finalizar tu estancia en \(r.salaUbicacion), Sala #\(r.salaNumero)?")
            }
        }
        .alert("Resultado", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("éxito") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func aceptarInvitacion(id: Int) {
        Task {
            let result = await aceptarUseCase.execute(reservaId: id)
            await MainActor.run {
                switch result {
                case .exito:
                    alertMessage = "¡Invitación aceptada con éxito!"
                    viewModel.fetchReservasActuales() // Actualizar lista
                case .error(let message):
                    alertMessage = "Error: \(message)"
                }
                showAlert = true
            }
        }
    }
    
    private func validarEscaneoDeSala(sala: Int, ubicacion: String) {
        // Prioridad 1: Buscar si el usuario ya tiene una reserva ACTIVA en esta sala (para finalizarla)
        let reservaActiva = viewModel.reservasFiltradas.first { r in
            r.salaNumero == sala && r.salaUbicacion == ubicacion && r.status == .activa
        }
        
        if let activa = reservaActiva {
            selectedReserva = activa
            isPresentingFinalization = true
            return
        }
        
        // Prioridad 2: Buscar si tiene una reserva por activar (ventana +/- 5 min)
        let ahora = Date()
        let cincoMinutos: TimeInterval = 5 * 60
        
        let coincidencia = viewModel.reservasFiltradas.first { r in
            let coincideSala = r.salaNumero == sala && r.salaUbicacion == ubicacion
            let inicioMenos5 = r.fechaHoraInicio.addingTimeInterval(-cincoMinutos)
            let inicioMas5 = r.fechaHoraInicio.addingTimeInterval(cincoMinutos)
            let coincideHora = ahora >= inicioMenos5 && ahora <= inicioMas5
            let esReservada = r.status == .reservada
            
            return coincideSala && coincideHora && esReservada
        }
        
        if let reserva = coincidencia {
            selectedReserva = reserva
            isPresentingActivation = true
        } else {
            alertMessage = "No se encontró una reserva activa o por iniciar en esta sala en este momento."
            showAlert = true
        }
    }
    
    private func activarReserva(id: Int) {
        Task {
            let result = await activarUseCase.execute(reservaId: id)
            await MainActor.run {
                switch result {
                case .exito:
                    alertMessage = "¡Reserva activada con éxito! Disfruta tu estancia."
                    // Forzar actualización total desde el servidor
                    viewModel.fetchReservasActuales()
                case .error(let message):
                    alertMessage = "Error al activar: \(message)"
                }
                showAlert = true
            }
        }
    }
    
    private func finalizarReserva(id: Int) {
        Task {
            let result = await finalizarUseCase.execute(reservaId: id)
            await MainActor.run {
                switch result {
                case .exito:
                    alertMessage = "¡Reserva finalizada con éxito! Gracias por usar Cubiko."
                    // Forzar actualización total desde el servidor
                    viewModel.fetchReservasActuales()
                case .error(let message):
                    alertMessage = "Error al finalizar: \(message)"
                }
                showAlert = true
            }
        }
    }
}



#Preview {
    CameraView(viewModel: ReservasViewModel())
}
