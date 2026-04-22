//
//  ButtonStyles.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/14/26.
//
import SwiftUI


struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.primaryCubiko)
            .cornerRadius(25)
    }
}


struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.secondaryCubiko)
            .cornerRadius(25)
    }
}


struct TertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.white)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.tertiaryButtonStroke, lineWidth: 1)
            )
    }
}


// Usage:
#Preview {
    VStack {
        Button("Click Me") { }
            .buttonStyle(PrimaryButtonStyle())
        
        Button("Click Me") { }
            .buttonStyle(SecondaryButtonStyle())
        
        Button("Click Me") { }
            .buttonStyle(TertiaryButtonStyle())
    }
    .padding()
}
