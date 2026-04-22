//
//  ReprogramarReservaUseCase.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//


import Foundation

final class ReprogramarReservaUseCase {

    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reservaActiva: Reserva, nuevaEntrada: Date, nuevaSalida: Date) async -> ReprogramacionEstado {
        // 1. Validaciones locales ultra rápidas (evitan peticiones innecesarias al servidor)
        guard nuevaSalida > nuevaEntrada else {
            return .errorDeRed("La hora de salida debe ser después de la entrada.")
        }
        guard nuevaEntrada > Date() else {
            return .errorDeRed("La hora de entrada debe ser en el futuro.")
        }

        // 2. Le pasamos el trabajo pesado al backend
        do {
            try await repository.reprogramarReserva(
                reservaId: reservaActiva.id,
                salaNumero: reservaActiva.salaNumero,
                salaUbicacion: reservaActiva.salaUbicacion,
                nuevaEntrada: nuevaEntrada,
                nuevaSalida: nuevaSalida,
                capacidad: reservaActiva.numPersonas
            )
            
            // Si el backend responde 200 OK (success: true), llegamos aquí
            return .exito
            
        } catch let error as URLError {
            // Error de conexión a internet
            return .errorDeRed("Error de conexión: \(error.localizedDescription)")
            
        } catch {
            // Aquí capturamos los errores del backend (los ApiError o throw ForbiddenError que mostró tu compañero)
            // Asumiendo que tu repositorio lanza un error personalizado con el 'message' del backend:
            return .conflicto(error.localizedDescription) 
        }
    }
}
