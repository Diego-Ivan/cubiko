//
//  HomeView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/15/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State var currentState: UserState = .login
    
    var body: some View {
        
        ZStack {
            if sessionManager.profile != nil {
                ContentView()
            } else {
                NavigationView {
                    if currentState == .login {
                        LoginView(currentState: $currentState)
                    } else if currentState == .register {
                        RegisterView(currentState: $currentState)
                    }
                }
            }
        }
    }
    
}

enum UserState {
    case login, register, main
}

#Preview {
    HomeView(currentState: .login)
        .environmentObject(SessionManager())
}
