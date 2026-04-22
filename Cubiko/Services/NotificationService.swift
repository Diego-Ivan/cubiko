//
//  NotificationService.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import Foundation
import UserNotifications

// MARK: - Tipos de notificación

enum CubikoNotificacion {
    case reservaProximaAIniciar(reserva: Reserva, minutosRestantes: Int)  // ← nuevo, separado
    case reservaProximaATerminar(reserva: Reserva, minutosRestantes: Int)
    case reservaConfirmada(reserva: Reserva)
    case reservaCancelada(reserva: Reserva)
    case multaPendiente(descripcion: String)
    case materialVencido(nombreMaterial: String)

    // Identificadores únicos — cada case tiene el suyo propio
    var identificador: String {
        switch self {
        case .reservaProximaAIniciar(let reserva, let mins):
            return "reserva-inicia-\(reserva.id)-\(mins)min"
        case .reservaProximaATerminar(let reserva, let mins):
            return "reserva-termina-\(reserva.id)-\(mins)min"
        case .reservaConfirmada(let reserva):
            return "reserva-confirmada-\(reserva.id)"
        case .reservaCancelada(let reserva):
            return "reserva-cancelada-\(reserva.id)"
        case .multaPendiente:
            return "multa-pendiente-\(UUID())"
        case .materialVencido(let nombre):
            return "material-vencido-\(nombre)"
        }
    }

    var content: UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.sound = .default

        switch self {
        case .reservaProximaAIniciar(let reserva, let mins):
            c.title = "🗓️ Tu reserva está por comenzar"
            c.body = "\(reserva.salaNumero) inicia en \(mins) minuto\(mins == 1 ? "" : "s"). ¡Dirígete al cubículo!"

        case .reservaProximaATerminar(let reserva, let mins):
            c.title = "⏰ Tu reserva está por terminar"
            c.body = "Te quedan \(mins) minuto\(mins == 1 ? "" : "s") en \(reserva.salaNumero). ¡Recuerda recoger tus cosas!"

        case .reservaConfirmada(let reserva):
            c.title = "✅ Reserva confirmada"
            c.body = "\(reserva.salaNumero) reservado de \(reserva.fechaHoraInicio.horaFormato) a \(reserva.fechaHoraFin.horaFormato)."

        case .reservaCancelada(let reserva):
            c.title = "❌ Reserva cancelada"
            c.body = "Tu reserva en \(reserva.salaNumero) fue cancelada."

        case .multaPendiente(let descripcion):
            c.title = "💳 Multa pendiente"
            c.body = descripcion

        case .materialVencido(let nombre):
            c.title = "📚 Material por devolver"
            c.body = "El plazo de '\(nombre)' ha vencido. Por favor devuélvelo a la brevedad."
        }

        return c
    }
}

// MARK: - Servicio

@MainActor
final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: Preferencias del usuario

    private var minutosAvisoFin: Int {
        UserDefaults.standard.integer(forKey: "minutosAvisoFin").nonZero ?? 15
    }

    private var minutosAvisoInicio: Int {
        UserDefaults.standard.integer(forKey: "minutosAvisoInicio").nonZero ?? 15
    }

    // MARK: Permisos

    func solicitarPermiso() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "✅ Permisos concedidos" : "⚠️ Permisos denegados — ve a Ajustes → Cubiko → Notificaciones")
        } catch {
            print("❌ Error solicitando permisos: \(error)")
        }
    }

    // MARK: Enviar inmediatamente

    func enviarAhora(_ notificacion: CubikoNotificacion) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        programar(notificacion, trigger: trigger)
    }

    // MARK: Programar para una fecha

    func programar(_ notificacion: CubikoNotificacion, en fecha: Date) {
        guard fecha > Date() else {
            print("⚠️ Fecha ya pasada, ignorando: \(notificacion.identificador)")
            return
        }
        let componentes = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fecha
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
        programar(notificacion, trigger: trigger)
    }

    // MARK: Recordatorios de reserva

    func programarRecordatoriosDeReserva(_ reserva: Reserva) {
        // — Aviso antes de INICIAR —
        let fechaAvisoInicio = reserva.fechaHoraInicio.addingTimeInterval(Double(-minutosAvisoInicio * 60))
        if fechaAvisoInicio > Date() {
            let notif = CubikoNotificacion.reservaProximaAIniciar(
                reserva: reserva,
                minutosRestantes: minutosAvisoInicio
            )
            programar(notif, en: fechaAvisoInicio)
            print("🔔 Aviso de INICIO programado: \(minutosAvisoInicio) min antes → \(fechaAvisoInicio.horaFormato)")
        } else {
            print("⚠️ Aviso de inicio omitido (fecha ya pasada)")
        }

        // — Aviso antes de TERMINAR —
        let fechaAvisoFin = reserva.fechaHoraFin.addingTimeInterval(Double(-minutosAvisoFin * 60))
        if fechaAvisoFin > Date() {
            let notif = CubikoNotificacion.reservaProximaATerminar(
                reserva: reserva,
                minutosRestantes: minutosAvisoFin
            )
            programar(notif, en: fechaAvisoFin)
            print("🔔 Aviso de FIN programado: \(minutosAvisoFin) min antes → \(fechaAvisoFin.horaFormato)")
        } else {
            print("⚠️ Aviso de fin omitido (fecha ya pasada)")
        }
    }

    // MARK: Cancelar

    func cancelarTodosLosRecordatorios(de reserva: Reserva, minutosInicio: Int, minutosFin: Int) {
        let ids = [
            CubikoNotificacion.reservaProximaAIniciar(reserva: reserva, minutosRestantes: minutosInicio).identificador,
            CubikoNotificacion.reservaProximaATerminar(reserva: reserva, minutosRestantes: minutosFin).identificador
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
        print("🗑️ Notificaciones canceladas: \(ids)")
    }

    // MARK: Privado

    private func programar(_ notificacion: CubikoNotificacion, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(
            identifier: notificacion.identificador,
            content: notificacion.content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("❌ Error al programar '\(notificacion.identificador)': \(error)")
            } else {
                print("✅ Programada: \(notificacion.identificador)")
            }
        }
    }
}

// MARK: - Helpers

private extension Date {
    var horaFormato: String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        return f.string(from: self)
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
