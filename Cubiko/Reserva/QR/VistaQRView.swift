//
//  VistaQRView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/7/26.
//

import SwiftUI

struct VistaQRView: View {

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
            
            VStack(spacing: 20) {
                Image("QR-Prueba")
                    .resizable()
                    .scaledToFit()
                
                Text("Escanee este código QR en el escáner para abrir la puerta")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
            }
            .transition(.scale.combined(with: .opacity))
            .padding()

        }
        .ignoresSafeArea()
    }
}

#Preview {
    VistaQRView()
}



/*
 
 VIEW
 
 @StateObject private var viewModel = QRViewModel()
 @State private var showQR = false

 var body: some View {
     VStack {
         if showQR {
             if viewModel.isLoading {
                 ProgressView()
             } else if let image = viewModel.qrImage {
                 Image(uiImage: image)
                     .resizable()
                     .scaledToFit()
                     .frame(width: 220, height: 220)
             } else if let error = viewModel.error {
                 Text(\"Error: \\(error.localizedDescription)\")
             }

             Button(\"Cerrar\") {
                 withAnimation { showQR = false }
             }
             .buttonStyle(.bordered)
         } else {
             Button(\"Mostrar QR\") {
                 withAnimation { showQR = true }
                 viewModel.fetchQR()
             }
             .buttonStyle(.borderedProminent)
         }
     }
     .padding()
 }
 */
