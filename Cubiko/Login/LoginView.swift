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
    // Accedemos al manager global
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
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
//                if isLoading {
//                    ProgressView()
//                }
//                
                Button(action: login) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Iniciar sesión")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isLoading) // Evita múltiples clics
                .padding(.horizontal, 36)
                .padding(.bottom, 12)
    
    
                Text("¿No tienes cuenta?")
                    .font(.footnote)
    
                Button {
                    currentState = .register
                } label: {
                    Text("Crear cuenta")
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
                    }
                )
            }
        }
    
    private func login() {
        // 1. Validaciones básicas
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor complete todos los campos."
            showAlert = true
            return
        }
        
        isLoading = true
        
        // 2. Configurar petición
        let url = APIConfig.baseURL.appendingPathComponent("api/auth/login")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // 3. Ejecutar petición
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }
                
                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      (200...201).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Credenciales incorrectas o error de servidor."
                    self.showAlert = true
                    return
                }
                
                // 4. Decodificar y Guardar en la Sesión
                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if let loginData = decoded.data {
                        // Creamos el perfil con el estudiante y sus tokens
                        
//                        let estudiante: Estudiante? = nil
                        let nuevoPerfil = UserProfile(
                            accessToken: loginData.access_token,
                            refreshToken: loginData.refresh_token,
                            expiresAt: Date().addingTimeInterval(3 * 30 * 24 * 60) // Ajustar según backend
                        )
                        
                        AuthManager.shared.login(accessToken: loginData.access_token, refreshToken: loginData.refresh_token ?? "")
                        
                        print("ACCESS TOKEN for debug: \(loginData.access_token)")
                        
                        sessionManager.updateProfile(nuevoPerfil)
                        
                        // Cambiamos el estado de la app
                        withAnimation {
                            currentState = .main
                        }
                    }
                } catch {
                    self.errorMessage = "Error al procesar los datos del usuario."
                    self.showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    @Previewable @State var currentState: UserState = .login
    
    LoginView(currentState: $currentState)
        .environmentObject(SessionManager())
}
