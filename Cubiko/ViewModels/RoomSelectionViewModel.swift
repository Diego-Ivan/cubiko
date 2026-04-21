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

    @Published var cubiculos: [Cubiculo] = []
    @Published var selectedCubiculo: Cubiculo? = nil

    private let repository: CubiculoRepositoryProtocol

    init(repository: CubiculoRepositoryProtocol = CubiculoRepositoryImpl()) {
        self.repository = repository
    }

    func cargarCubiculos() {
        cubiculos = repository.obtenerTodos()
    }
}

