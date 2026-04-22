//
//  ReservaListView.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/21/26.
//

import SwiftUI

struct ReservaListView: View {
    let reserva: Reserva
    let esPrimera: Bool
    
    var textColor: Color {
        if esPrimera {
            return .white
        }
        return .black
    }
    
    var bgColor: Color {
        if esPrimera {
            return Color.primaryCubiko
        }
        return .white
    }
    
    var symbol: String {
        if reserva.numPersonas == 1 {
            return "person.fill"
        } else if reserva.numPersonas == 2 {
            return "person.2.fill"
        }
        return "person.3.fill"
    }
    
    var body: some View {
        
        NavigationLink {
            ReservaDetalleView(reserva: reserva)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Sala #\(reserva.salaNumero)")
                        .font(.title2)
                        .foregroundColor(textColor)
                        .bold()
                    
                    if Calendar.current.isDate(reserva.fechaInicio, inSameDayAs: reserva.fechaFin)  {
                        Text(reserva.fechaInicio.formatted(date: .abbreviated, time: .omitted))
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                    } else {
                        Text("\(reserva.fechaInicio.formatted(date: .abbreviated, time: .omitted)) - \(reserva.fechaFin.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    
                    
                    Text("\(reserva.fechaInicio.formatted(date: .omitted, time: .shortened)) - \(reserva.fechaFin.formatted(date: .omitted, time: .shortened))")
                        .font(.headline)
                        .foregroundColor(textColor)
                }
                
                Spacer()
                
                Image(systemName: symbol)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80) // Adjust size as needed
                    .foregroundColor(textColor)
                    .padding(.trailing, 10) // Indent icon from right edge of card
                
                if esPrimera {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                        .font(.callout)
                }
            }
        }
        .foregroundStyle(.white, .red)
        .listRowBackground(bgColor)
        .tint(.white)
        .navigationLinkIndicatorVisibility(esPrimera ? .hidden : .visible)
    }
}
