//
//  QRViewModel.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/7/26.
//

import SwiftUI

@Observable
class QRViewModel {
    var qrImage: UIImage?
    var isLoading: Bool = false
    var error: String?

    private let obtenerQrAccesoUseCase: ObtenerQrAccesoUseCase

    init(repository: CubiculoRepositoryProtocol = RealRoomRepository()) {
        self.obtenerQrAccesoUseCase = ObtenerQrAccesoUseCase(repository: repository)
    }

    func fetchQR(reservaId: Int) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let data = try await obtenerQrAccesoUseCase.execute(reservaId: reservaId)
                
                await MainActor.run {
                    if let image = UIImage(data: data) {
                        self.qrImage = image
                    } else {
                        self.error = "No se pudo generar la imagen del QR"
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
