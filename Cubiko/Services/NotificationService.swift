//
//  NotificationService.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import Foundation
import UserNotifications

// MARK: - Tipos de notificación

/// Cada case representa un evento distinto de la app.
/// Para agregar un tipo nuevo, solo añades un case aquí
/// y defines su contenido en `content` más abajo.

enum CubikoNotificacion {
    case reservaProximaATerminar(reserva: Reserva, minutosRestantes: Int)
    case reservaConfirmada(reserva: Reserva)
    case reservaCancelada(reserva: Reserva)
    case multaPendiente(descripcion: String)
    case materialVencido(nombreMaterial: String)

    // Identificador único para poder cancelar notificaciones programadas
    var identificador: String {
        switch self {
        case .reservaProximaATerminar(let reserva, let mins):
            return "reserva-expira-\(reserva.id)-\(mins)min"
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

    // El contenido (título + cuerpo) que verá el usuario
    var content: UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.sound = .default

        switch self {
        case .reservaProximaATerminar(let reserva, let mins):
            c.title = "Tu reserva está por terminar"
            c.body = "Te quedan \(mins) minuto\(mins == 1 ? "" : "s") en \(reserva.cubiculo.nombre). ¡Recuerda recoger tus cosas!"

        case .reservaConfirmada(let reserva):
            c.title = "Reserva confirmada"
            c.body = "\(reserva.cubiculo.nombre) reservado del \(reserva.inicio.horaFormato) al \(reserva.fin.horaFormato)."

        case .reservaCancelada(let reserva):
            c.title = "Reserva cancelada"
            c.body = "Tu reserva en \(reserva.cubiculo.nombre) fue cancelada."

        case .multaPendiente(let descripcion):
            c.title = "Multa pendiente"
            c.body = descripcion

        case .materialVencido(let nombre):
            c.title = "Material por devolver"
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

    // MARK: Permisos

    /// Llama esto al arrancar la app (en CubikoApp.swift)
    func solicitarPermiso() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "Permisos de notificación concedidos" : "Permisos denegados")
        } catch {
            print("Error solicitando permisos: \(error)")
        }
    }

    // MARK: Enviar inmediatamente

    /// Muestra una notificación al instante (útil para confirmaciones, cancelaciones, multas, etc.)
    func enviarAhora(_ notificacion: CubikoNotificacion) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        programar(notificacion, trigger: trigger)
    }

    // MARK: Programar para más tarde

    /// Programa una notificación para que se dispare en una fecha específica.
    /// Funciona aunque la app esté cerrada.
    func programar(_ notificacion: CubikoNotificacion, en fecha: Date) {
        guard fecha > Date() else {
            print("⚠️ La fecha ya pasó, notificación ignorada")
            return
        }
        let componentes = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fecha
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: componentes, repeats: false)
        programar(notificacion, trigger: trigger)
    }

    // MARK: Notificaciones de reserva

    /// Programa todos los recordatorios de una reserva de una vez.
    /// Actualmente avisa a los 15 y 5 minutos antes de que termine.
    func programarRecordatoriosDeReserva(_ reserva: Reserva) {
        let avisos = [15, 5] // minutos antes

        for mins in avisos {
            let fechaAviso = reserva.fin.addingTimeInterval(Double(-mins * 60))
            guard fechaAviso > Date() else { continue }

            let notificacion = CubikoNotificacion.reservaProximaATerminar(
                reserva: reserva,
                minutosRestantes: mins
            )
            programar(notificacion, en: fechaAviso)
            print("🔔 Aviso programado: \(mins) min antes (\(fechaAviso.horaFormato))")
        }
    }

    // MARK: Cancelar

    func cancelar(_ notificacion: CubikoNotificacion) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificacion.identificador])
    }

    func cancelarTodosLosRecordatorios(de reserva: Reserva) {
        let ids = [15, 5].map { mins in
            CubikoNotificacion.reservaProximaATerminar(
                reserva: reserva,
                minutosRestantes: mins
            ).identificador
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
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
                print("Error al programar notificación: \(error)")
            }
        }
    }
}

// MARK: - Helper de formato de fechas

private extension Date {
    var horaFormato: String {
        let f = DateFormatter()
        f.timeStyle = .short
        f.locale = Locale(identifier: "es_MX")
        return f.string(from: self)
    }
}
