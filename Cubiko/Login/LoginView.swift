//
//  LoginView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/13/26.
//

import SwiftUI
import Foundation


struct LoginView: View {
    @Binding var currentState: UserState
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Inicio de sesión")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 32)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Correo electrónico")
                        .font(.headline)
                    
                    EmailTextField(email: $email)
                    
                    
                    Text("Contraseña")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    SecureTextField("Escriba su contraseña", text: $password)

                }
                
                Spacer()
            }
            .padding(.horizontal, 36)
            Spacer()
            if isLoading {
                ProgressView()
            }
            
            Button(action: login) {
                Text("Iniciar sesión")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 36)
            .padding(.bottom, 12)
            
            
            Text("¿No tienes cuenta?")
                .font(.footnote)
            
            Button {
                currentState = .register
            } label: {
                Text("Registrarme")
            }
            .buttonStyle(TertiaryButtonStyle())
            .padding(.horizontal, 36)
            .padding(.bottom, 36)
        }
        .background(Color.white)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorMessage ?? "Error" ),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    errorMessage = nil
                    successMessage = nil
                }
            )
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor complete todos los campos."
            showAlert = true
            successMessage = nil
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        guard let url = URL(string: "http://localhost:3001/api/auth/login") else {
            errorMessage = "URL inválida."
            showAlert = true
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [
            "email": email,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error de red: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      let data = data else {
                    errorMessage = "Respuesta inválida."
                    showAlert = true
                    return
                }
                if let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    if httpResponse.statusCode == 201, decoded.success, let _ = decoded.data {
                        successMessage = decoded.message ?? "¡Inicio de sesión exitoso!"
                        
                        currentState = .main
                        
                    } else {
                        errorMessage = decoded.error ?? decoded.message ?? "Error de autenticación."
                        showAlert = true
                        return
                    }
                    
                } else {
                    errorMessage = "No se pudo parsear la respuesta."
                    showAlert = true
                }
                print("Status code:", httpResponse.statusCode)
                print("Raw response:", String(data: data, encoding: .utf8) ?? "N/A")
            }
        }.resume()
    }
}

#Preview {
    @Previewable @State var currentState: UserState = .login
    
    LoginView(currentState: $currentState)
}
