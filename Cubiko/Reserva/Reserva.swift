//
//  Reserva.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 08/04/26.
//

import Foundation

struct Reserva: Identifiable, Codable, Equatable {
    let id: Int
    let estudianteId: Int
    let salaUbicacion: String
    let salaNumero: Int
    let fechaInicio: Date
    let fechaFin: Date
    
    let horaInicio: DateComponents
    let horaFin: DateComponents

    let numPersonas: Int
    var status: Status = .activa

    enum Status: String, Codable, CaseIterable {
        case activa = "Activa"
        case completada = "Completada"
        case cancelada = "Cancelada"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case estudianteId = "estudiante_id"
        case salaUbicacion = "sala_ubicacion"
        case salaNumero = "sala_numero"
        case fechaInicio
        case fechaFin
        case horaInicio
        case horaFin
        case numPersonas
        case status
    }
    
    init(id: Int, estudianteId: Int, salaUbicacion: String, salaNumero: Int, fechaInicio: Date, fechaFin: Date, horaInicio: DateComponents, horaFin: DateComponents, numPersonas: Int, status: Status = .activa) {
        self.id = id
        self.estudianteId = estudianteId
        self.salaUbicacion = salaUbicacion
        self.salaNumero = salaNumero
        self.fechaInicio = fechaInicio
        self.fechaFin = fechaFin
        self.horaInicio = horaInicio
        self.horaFin = horaFin
        self.numPersonas = numPersonas
        self.status = status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        estudianteId = try container.decodeIfPresent(Int.self, forKey: .estudianteId) ?? 0
        salaUbicacion = try container.decodeIfPresent(String.self, forKey: .salaUbicacion) ?? ""
        salaNumero = try container.decodeIfPresent(Int.self, forKey: .salaNumero) ?? 0
        
        let fechaInicioStr = try container.decode(String.self, forKey: .fechaInicio)
        let fechaFinStr = try container.decode(String.self, forKey: .fechaFin)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let d = formatter.date(from: fechaInicioStr) ?? ISO8601DateFormatter().date(from: fechaInicioStr) {
            fechaInicio = d
        } else {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            fechaInicio = df.date(from: fechaInicioStr) ?? Date()
        }

        if let d = formatter.date(from: fechaFinStr) ?? ISO8601DateFormatter().date(from: fechaFinStr) {
            fechaFin = d
        } else {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            fechaFin = df.date(from: fechaFinStr) ?? Date()
        }

        let horaInicioStr = try container.decode(String.self, forKey: .horaInicio)
        let horaFinStr = try container.decode(String.self, forKey: .horaFin)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        if let d = timeFormatter.date(from: horaInicioStr) {
            horaInicio = Calendar.current.dateComponents([.hour, .minute, .second], from: d)
        } else {
            timeFormatter.dateFormat = "HH:mm"
            if let d2 = timeFormatter.date(from: horaInicioStr) {
                horaInicio = Calendar.current.dateComponents([.hour, .minute], from: d2)
            } else {
                horaInicio = DateComponents()
            }
        }

        timeFormatter.dateFormat = "HH:mm:ss"
        if let d = timeFormatter.date(from: horaFinStr) {
            horaFin = Calendar.current.dateComponents([.hour, .minute, .second], from: d)
        } else {
            timeFormatter.dateFormat = "HH:mm"
            if let d2 = timeFormatter.date(from: horaFinStr) {
                horaFin = Calendar.current.dateComponents([.hour, .minute], from: d2)
            } else {
                horaFin = DateComponents()
            }
        }
        
        numPersonas = try container.decodeIfPresent(Int.self, forKey: .numPersonas) ?? 1
        status = try container.decodeIfPresent(Status.self, forKey: .status) ?? .activa
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(estudianteId, forKey: .estudianteId)
        try container.encode(salaUbicacion, forKey: .salaUbicacion)
        try container.encode(salaNumero, forKey: .salaNumero)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(dateFormatter.string(from: fechaInicio), forKey: .fechaInicio)
        try container.encode(dateFormatter.string(from: fechaFin), forKey: .fechaFin)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        if let d = Calendar.current.date(from: horaInicio) {
            try container.encode(timeFormatter.string(from: d), forKey: .horaInicio)
        }
        if let d = Calendar.current.date(from: horaFin) {
            try container.encode(timeFormatter.string(from: d), forKey: .horaFin)
        }
        
        try container.encode(numPersonas, forKey: .numPersonas)
        try container.encode(status, forKey: .status)
    }

    var fechaHoraInicio: Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: fechaInicio)
        comps.hour = horaInicio.hour
        comps.minute = horaInicio.minute
        comps.second = horaInicio.second
        return cal.date(from: comps) ?? fechaInicio
    }

    var fechaHoraFin: Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: fechaFin)
        comps.hour = horaFin.hour
        comps.minute = horaFin.minute
        comps.second = horaFin.second
        return cal.date(from: comps) ?? fechaFin
    }

    /// Minutos que faltan para que termine la reserva (puede ser negativo si ya terminó)
    var minutosRestantes: Double? {
        return fechaHoraFin.timeIntervalSinceNow / 60
    }

    var yaTermino: Bool {
        return Date() >= fechaHoraFin
    }
}
