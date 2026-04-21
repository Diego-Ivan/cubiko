//
//  RegisterView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/13/26.
//

import SwiftUI

struct RegisterView: View {
    @Binding var currentState: UserState

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Registro")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 32)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("Nombre")
                        .font(.headline)

                    PrimaryTextField("Escriba su nombre", text: $name)
                    
                    
                    Text("Correo electrónico")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    EmailTextField(email: $email)
                    
                    
                    Text("Contraseña")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    SecureTextField("Escriba su contraseña", text: $password)

                    
                    Text("Confirmar contraseña")
                        .font(.headline)
                        .padding(.top, 8)
                
                    SecureTextField("Repita su contraseña", text: $confirmPassword)
                }
                
                Spacer()

            }
            .padding(.horizontal, 36)
            Spacer()
            
            if isLoading {
                ProgressView()
            }
            
            Button(action: register) {
                Text("Registrarse")
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 12)
            .buttonStyle(PrimaryButtonStyle())
            
            Text("¿Ya tienes cuenta?")
                .font(.footnote)
            
            Button {
                currentState = .login
            } label: {
                Text("Iniciar sesión")
            }
            .padding(.horizontal, 36)
            .padding(.bottom, 36)
            .buttonStyle(TertiaryButtonStyle())
                
                
            
        }
        .background(Color.white)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorMessage != nil ? "Error" : "Éxito"),
                message: Text(errorMessage ?? successMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    errorMessage = nil
                    successMessage = nil
                }
            )
        }
    }
    
    private func register() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Por favor complete todos los campos."
            showAlert = true
            successMessage = nil
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            showAlert = true
            successMessage = nil
            return
        }
        errorMessage = nil
        successMessage = nil
        isLoading = true
        guard let url = URL(string: "http://localhost:3001/api/auth/register") else {
            errorMessage = "URL de registro inválida."
            showAlert = true
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "nombre": name,
            "email": email,
            "password": password,
//            "status": "Activo"
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
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    errorMessage = "Respuesta inválida del servidor."
                    showAlert = true
                    return
                }
                if httpResponse.statusCode == 201 {
                    if let decoded = try? JSONDecoder().decode(RegisterResponse.self, from: data),
                       decoded.success, let token = decoded.data?.access_token {
                        successMessage = "¡Registro exitoso! Token: \(token.prefix(12))..."
                        showAlert = true
                    } else {
                        errorMessage = "No se pudo procesar la respuesta del servidor."
                        showAlert = true
                    }
                } else if httpResponse.statusCode == 409 {
                    if let decoded = try? JSONDecoder().decode(RegisterResponse.self, from: data) {
                        errorMessage = decoded.message ?? "El correo ya está en uso."
                        showAlert = true
                    } else {
                        errorMessage = "El correo ya está en uso."
                        showAlert = true
                    }
                } else {
                    if let decoded = try? JSONDecoder().decode(RegisterResponse.self, from: data) {
                        errorMessage = decoded.message ?? "Error al registrarse."
                        showAlert = true
                        
                        print("Status code:", httpResponse.statusCode)
                        print("Raw response:", String(data: data, encoding: .utf8) ?? "N/A")
                        
                    } else {
                        errorMessage = "Error al registrarse 2."
                        showAlert = true
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    @Previewable @State var currentState: UserState = .login

    RegisterView(currentState: $currentState)
}
