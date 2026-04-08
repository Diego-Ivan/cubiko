//
//  VistaQRView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/7/26.
//

import SwiftUI

struct VistaQRView: View {
    @State private var showQR = false

    var body: some View {
        VStack(spacing: 24) {
            if showQR {
                VStack(spacing: 20) {
                    Image("QR-Prueba")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                    
                    Text("Escanee este código QR en el escáner para abrir la puerta")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    
                    Button("Cerrar") {
                        withAnimation {
                            showQR = false
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .transition(.scale.combined(with: .opacity))
                .padding(30)
                .background(.gray.opacity(0.1))
                .clipShape(
                    RoundedRectangle(cornerRadius: 30)
                )
                .padding(30)
            } else {
                Button("Mostrar QR") {
                    withAnimation {
                        showQR = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .animation(.spring(), value: showQR)
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
