//
//  ReservaCard.swift
//  Cubiko
//
//  Created by Azuany Mila Cerón on 4/15/26.
//
import SwiftUI

struct ReservaCard: View {
    let reserva: Reserva
    
     var body: some View {
         HStack(alignment: .top) {
             VStack(alignment: .leading) {
                 HStack(alignment: .top) {
                     VStack(alignment: .leading, spacing: 8) {
                         Text(reserva.cubiculo.nombre)
                             .font(.largeTitle)
                             .fontWeight(.bold)
                             .foregroundColor(.white)
                         
                         if Calendar.current.isDate(reserva.inicio, inSameDayAs: reserva.fin)  {
                             Text(reserva.inicio.formatted(date: .abbreviated, time: .omitted))
                                 .font(.title3)
                                 .foregroundColor(.white)
                         } else {
                             Text("\(reserva.inicio.formatted(date: .abbreviated, time: .omitted)) - \(reserva.fin.formatted(date: .abbreviated, time: .omitted))")
                                 .font(.title3)
                                 .foregroundColor(.white)
                         }
                         
                         
                         Text("\(reserva.inicio.formatted(date: .omitted, time: .shortened)) - \(reserva.fin.formatted(date: .omitted, time: .shortened))")
                             .font(.title3)
                             .foregroundColor(.white)
                     }
                     .padding(.leading, 20) // Indent text from left edge of card
                     
                     Spacer()
                     
                     if reserva.cubiculo.tipo == "Individual" {
                         Image(systemName: "person.fill")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 100, height: 100) // Adjust size as needed
                             .foregroundColor(.white)
                             .padding(.trailing, 20) // Indent icon from right edge of card
                         
                     }
                 }
                 .padding(.top, 20) // Padding from top of card
                 .padding(.bottom, 50)
                 
                 
                 Button {
                     
                 } label: {
                     Text ("Tap para QR de reserva")
                         .font(.caption)
                         .foregroundColor(.white)
                         .frame(maxWidth: .infinity, alignment: .center) // Center horizontally
                         .padding(.bottom, 20) // Padding from bottom of card
                 }
//                 .buttonStyle(TertiaryButtonStyle())
                 
             }
             .frame(maxWidth: .infinity, minHeight: 100, idealHeight: 295, maxHeight: 500) // Maintain height, allow width to adapt with padding
             .background(Color(red: 0.16, green: 0.44, blue: 0.59))
             .cornerRadius(20)
         }
    }
}

#Preview {
    ReservaCard(reserva: Reserva(id: UUID(), cubiculo: Cubiculo(id: 1, nombre: "Sala 1", tipo: "Individual"), inicio: Date(), fin: Date()))
}
