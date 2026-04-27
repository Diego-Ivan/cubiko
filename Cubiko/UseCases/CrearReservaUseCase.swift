//
//  CrearReservaUseCase.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/22/26.
//


import Foundation

final class CrearReservaUseCase {
    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(sala: SalaDisponible, inicio: Date, fin: Date, capacidad: Int?) async -> CrearReservaEstado {
        
        // 1. Validación local (Replicando la lógica de Zod: end > start)
        guard fin > inicio else {
            return .error("La hora de fin debe ser posterior a la de inicio.")
        }
        
        guard inicio > Date() else {
            return .error("No puedes crear reservas en el pasado.")
        }
        
        // 2. Ejecución hacia el backend
        do {
            let nuevaReservaId = try await repository.crearReserva(
                salaNumero: sala.numero,
                salaUbicacion: sala.ubicacion,
                inicio: inicio,
                fin: fin,
                capacidad: capacidad
            )
            
            return .exito(reservaId: nuevaReservaId)
            
        } catch let error as URLError {
            return .error("Error de conexión: \(error.localizedDescription)")
        } catch {
            return .error(error.localizedDescription)
        }
    }
    
    private func combinar(fecha: Date, hora: Date) -> Date {
        let calendar = Calendar.current
        let componentesFecha = calendar.dateComponents([.year, .month, .day], from: fecha)
        let componentesHora = calendar.dateComponents([.hour, .minute], from: hora)
        
        var final = DateComponents()
        final.year = componentesFecha.year
        final.month = componentesFecha.month
        final.day = componentesFecha.day
        final.hour = componentesHora.hour
        final.minute = componentesHora.minute
        
        return calendar.date(from: final) ?? Date()
    }
}
