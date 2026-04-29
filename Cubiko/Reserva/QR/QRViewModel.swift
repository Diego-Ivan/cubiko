//
//  QRViewModel.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/7/26.
//

import SwiftUI
import SVGKit
import CoreImage.CIFilterBuiltins

@Observable
class QRViewModel {
    var qrImage: UIImage?
    var isLoading: Bool = true
    var error: String?
    var qrData: Data? = nil

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
                    self.qrData = data
                    let svgImage = SVGKImage(data: data)
                    self.qrImage = svgImage?.uiImage
//                } else {
//                        self.error = "No se pudo generar la imagen del QR"
//                    }
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
    
    func createQR(reservaId: Int) {
        isLoading = true
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Convert string to UTF-8 data
        let data = Data(String(reservaId).utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        // Optional: Set Error Correction Level (L, M, Q, or H)
        // "H" allows for 30% recovery if the code is damaged
        filter.setValue("H", forKey: "inputCorrectionLevel")

        if let outputImage = filter.outputImage {
            print("QR VM: creating QR code")
            // Scale the image up so it isn't blurry when displayed
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                self.qrImage = UIImage(cgImage: cgImage)
            } else {
                print("QR VM: ERROR with context")
            }
        } else {
            print("QR VM: ERROR with filter")
        }
        
        isLoading = false
    }
}
