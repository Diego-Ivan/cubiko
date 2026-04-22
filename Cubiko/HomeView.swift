//
//  HomeView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/15/26.
//

import SwiftUI

struct HomeView: View {
    @State var currentState: UserState = .login
    
    var body: some View {
        
        NavigationView {
            ZStack {
                ContentView()
                /*
                if currentState == .login {
                    LoginView(currentState: $currentState)
                } else if currentState == .register {
                    RegisterView(currentState: $currentState)
                } else if currentState == .main {
                    ContentView()
                }*/
            }
        }
    }
    
}

enum UserState {
    case login, register, main
}

#Preview {
    HomeView()
}
