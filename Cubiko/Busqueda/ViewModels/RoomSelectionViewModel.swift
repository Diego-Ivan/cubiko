//
//  RoomSelectionViewModel.swift
//  Cubiko
//
//  Created by Emiliano Ruíz Plancarte on 13/04/26.
//

import Foundation
import Combine

@MainActor
final class RoomSelectionViewModel: ObservableObject {

    @Published var salas: [Sala] = []
    @Published var selectedSala: Sala? = nil

    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol) {
        self.repository = repository
    }

//    func cargarCubiculos() {
//        cubiculos = repository.obtenerTodos()
//    }
}
