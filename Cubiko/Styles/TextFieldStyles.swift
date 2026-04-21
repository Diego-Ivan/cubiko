//
//  TextFieldStyles.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/14/26.
//

import SwiftUI

import SwiftUI


struct PrimaryTextField: View {
    let title: String
    @Binding var text: String
    
    init(
        _ title: String = "",
        text: Binding<String>
    ) {
        self.title = title
        self._text = text
    }
        
    
    var body: some View {
        TextField(
            title,
            text: $text,
            prompt: Text(title)
                .foregroundStyle(.textField)
        )
        .padding()
        .background(Color.cubikoBg)
        .cornerRadius(8)
    }
}



struct EmailTextField: View {
    let title: String = "Escriba su correo"
    @Binding var email: String
    
    var body: some View {
        TextField(
            title,
            text: $email,
            prompt: Text(title)
                .foregroundStyle(.textField)
        )
        .padding()
        .background(Color.cubikoBg)
        .cornerRadius(8)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .textInputAutocapitalization(.never) // Prevents "Email@example.com"
        .autocorrectionDisabled(true)
    }
}

struct SecureTextField: View {
    let title: String
    @Binding var text: String
    
    init(
        _ title: String = "",
        text: Binding<String>
    ) {
        self.title = title
        self._text = text
    }
    
    
    var body: some View {
        SecureField(
            title,
            text: $text,
            prompt: Text(title)
                .foregroundStyle(.textField)
        )
        .padding()
        .background(Color.cubikoBg)
        .cornerRadius(8)
        
    }
}


#Preview {
    @Previewable @State var email: String = ""
    
    VStack {
        
        PrimaryTextField("Email", text: $email)
        
        EmailTextField(email: $email)
        
        SecureTextField("Escriba su contraseña", text: $email)

    }
    .padding()
}
