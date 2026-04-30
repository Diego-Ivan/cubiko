//
//  RegisterView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/13/26.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var sessionManager: SessionManager

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

            Button(action: register) {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Crear cuenta")
                }
            }
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1.0)
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
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            showAlert = true
            return
        }

        isLoading = true
        let url = APIConfig.baseURL.appendingPathComponent("api/auth/register")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["nombre": name, "email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error de red: \(error.localizedDescription)"
                    self.isLoading = false
                    self.showAlert = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "Respuesta inválida del servidor."
                    self.isLoading = false
                    self.showAlert = true
                }
                return
            }

            if httpResponse.statusCode == 201 {
                performSilentLogin()
            } else {
                DispatchQueue.main.async {
                    struct BackendError: Decodable { let message: String?; let error: String? }
                    let decoded = try? JSONDecoder().decode(BackendError.self, from: data)
                    self.errorMessage = decoded?.message ?? decoded?.error ?? "Error al registrarse (\(httpResponse.statusCode))"
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    private func performSilentLogin() {
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
                    self.errorMessage = "Registro exitoso, pero hubo un error al iniciar sesión: \(error.localizedDescription)"
                    self.showAlert = true
                    return
                }

                guard let data = data,
                      let httpResponse = response as? HTTPURLResponse,
                      (200...201).contains(httpResponse.statusCode) else {
                    self.errorMessage = "Registro exitoso, pero el login automático falló. Por favor inicie sesión manualmente."
                    self.showAlert = true
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    if let loginData = decoded.data {
                        let expiresAt = Date().addingTimeInterval(90 * 24 * 60 * 60)
                        sessionManager.login(
                            accessToken: loginData.access_token,
                            refreshToken: loginData.refresh_token,
                            expiresAt: expiresAt
                        )
                        withAnimation { currentState = .main }
                    }
                } catch {
                    self.errorMessage = "Error al procesar el login tras el registro."
                    self.showAlert = true
                }
            }
        }.resume()
    }
}
