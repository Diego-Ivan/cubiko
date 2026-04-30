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

            Button(action: login) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Iniciar sesión")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(isLoading)
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
                title: Text(errorMessage ?? "Error"),
                message: Text(errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    errorMessage = nil
                }
            )
        }
    }

    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor complete todos los campos."
            showAlert = true
            return
        }

        isLoading = true

        let url = APIConfig.baseURL.appendingPathComponent("api/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showAlert = true
                    return
                }

                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Error de conexión con el servidor."
                    self.showAlert = true
                    return
                }

                guard (200...201).contains(httpResponse.statusCode) else {
                    struct BackendError: Decodable {
                        let success: Bool?
                        let message: String?
                        let error: String?
                    }
                    let decoded = try? JSONDecoder().decode(BackendError.self, from: data)
                    self.errorMessage = decoded?.message ?? decoded?.error ?? "Error \(httpResponse.statusCode): Credenciales incorrectas o error de servidor."
                    self.showAlert = true
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    if let loginData = decoded.data {
                        // Aproximado: 90 días. Ajustar según expires_in del backend.
                        let expiresAt = Date().addingTimeInterval(90 * 24 * 60 * 60)
                        sessionManager.login(
                            accessToken: loginData.access_token,
                            refreshToken: loginData.refresh_token,
                            expiresAt: expiresAt
                        )
                        withAnimation { currentState = .main }
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
