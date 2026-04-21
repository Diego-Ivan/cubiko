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
    var isLoading = false
    var error: Error?

    func fetchQR() {
        guard let apiURL = URL(string: "https://your.api/qr") else { return }
        isLoading = true
        error = nil
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: apiURL)
                let response = try JSONDecoder().decode(QRResponse.self, from: data)
                let (imgData, _) = try await URLSession.shared.data(from: response.qrURL)
                if let image = UIImage(data: imgData) {
                    await MainActor.run { self.qrImage = image }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
            await MainActor.run { self.isLoading = false }
        }
    }
}
