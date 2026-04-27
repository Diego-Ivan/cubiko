//
//  VistaQRView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/7/26.
//

import SwiftUI

struct VistaQRView: View {
    let reservaId: Int
    @State private var viewModel = QRViewModel()

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Generando QR...")
                } else if let error = viewModel.error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if let image = viewModel.qrImage {
                    Image(uiImage: image)
                        .resizable()
                        .interpolation(.none) // Para que el QR se vea nítido
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                } else {
                    Text("No se pudo cargar el QR")
                }
                
                Text("Escanee este código QR en el escáner para abrir la puerta")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
            }
            .transition(.scale.combined(with: .opacity))
            .padding()

        }
        .ignoresSafeArea()
        .task {
            viewModel.fetchQR(reservaId: reservaId)
        }
    }
}

#Preview {
    VistaQRView(reservaId: 1)
}

