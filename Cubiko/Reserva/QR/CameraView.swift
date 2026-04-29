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
    var reservas: [Reserva] = []
    
    @State private var isPresentingInvitation = false
    @State private var isPresentingActivation = false
    @State private var scannedCode: String?
    @State private var selectedReserva: Reserva?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    
    private let aceptarUseCase = AceptarInvitacionConQrUseCase(repository: RealRoomRepository())
    private let activarUseCase = ActivarReservaUseCase(repository: RealRoomRepository())

    var body: some View {
        
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
                    validarActivacion(sala: roomNum, ubicacion: roomUbicacion)
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
                Text("¿Deseas activar tu reserva en \(r.salaUbicacion) (\(r.salaNumero))?")
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
                case .error(let message):
                    alertMessage = "Error: \(message)"
                }
                showAlert = true
            }
        }
    }
    
    private func validarActivacion(sala: Int, ubicacion: String) {
        let ahora = Date()
        let cincoMinutos: TimeInterval = 5 * 60
        
        // Buscar una reserva que coincida con la sala y la hora (+/- 5 min)
        let coincidencia = reservas.first { r in
            let coincideSala = r.salaNumero == sala && r.salaUbicacion == ubicacion
            let inicioMenos5 = r.fechaHoraInicio.addingTimeInterval(-cincoMinutos)
            let inicioMas5 = r.fechaHoraInicio.addingTimeInterval(cincoMinutos)
            let coincideHora = ahora >= inicioMenos5 && ahora <= inicioMas5
            
            return coincideSala && coincideHora
        }
        
        if let reserva = coincidencia {
            selectedReserva = reserva
            isPresentingActivation = true
        } else {
            alertMessage = "No se encontró una reserva válida para esta sala en este horario (ventana de +/- 5 min)."
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
                case .error(let message):
                    alertMessage = "Error al activar: \(message)"
                }
                showAlert = true
            }
        }
    }
}



#Preview {
    CameraView()
}
