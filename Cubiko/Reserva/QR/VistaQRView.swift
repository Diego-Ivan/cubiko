//
//  VistaQRView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/7/26.
//

import SwiftUI


struct VistaQRView: View {
    let reservaId: Int
    let bitmapSize = CGSize(width: 500, height: 500)
    @State private var viewModel = QRViewModel()

    var body: some View {
        ZStack(alignment: .center) {
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
                            .scaledToFit()
                            .frame(maxWidth: 400, maxHeight: 400)
                            .padding()

                } else {
                    Text("No se pudo cargar el QR")
                }
                
                Text("Comparta este código QR para añadir personas a tu reserva")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
            }
            .transition(.scale.combined(with: .opacity))
            .padding()

        }
        .ignoresSafeArea()
        .task {
            viewModel.createQR(reservaId: reservaId)
        }
    }
}

#Preview {
    VistaQRView(reservaId: 1)
}
