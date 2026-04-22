//
//  BuscarCubiculosDisponiblesUseCase.swift
//  Cubiko
//
//  Created by Rafael on 13/04/26.
//

//import Foundation

//final class BuscarCubiculosDisponiblesUseCase {
//
//    private let repository: CubiculoRepositoryProtocol
//
//    init(repository: CubiculoRepositoryProtocol) {
//        self.repository = repository
//    }
//
//    func execute(inicio: Date, fin: Date) -> [Cubiculo] {
//        let reservas = repository.obtenerReservas()
//        return repository.obtenerTodos().filter { cubiculo in
//            !reservas.contains { r in
//                r.cubiculo.id == cubiculo.id &&
//                r.inicio < fin &&
//                r.fin > inicio
//            }
//        }
//    }
//}
