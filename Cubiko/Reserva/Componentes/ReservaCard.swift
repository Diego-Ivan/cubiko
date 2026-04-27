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
                         Text("Sala #\(reserva.salaNumero)")
                             .font(.largeTitle)
                             .fontWeight(.bold)
                             .foregroundColor(.white)
                         
                         if Calendar.current.isDate(reserva.fechaHoraInicio, inSameDayAs: reserva.fechaHoraFin)  {
                             Text(reserva.fechaInicio.formatted(date: .abbreviated, time: .omitted))
                                 .font(.title3)
                                 .foregroundColor(.white)
                         } else {
                             Text("\(reserva.fechaHoraInicio.formatted(date: .omitted, time: .shortened)) - \(reserva.fechaHoraFin.formatted(date: .omitted, time: .shortened))")
                                 .font(.title3)
                                 .foregroundColor(.white)
                         }
                         
                         
                         Text("\(reserva.fechaHoraInicio.formatted(date: .omitted, time: .shortened)) - \(reserva.fechaHoraFin.formatted(date: .omitted, time: .shortened))")
                             .font(.title3)
                             .foregroundColor(.white)
                     }
                     .padding(.leading, 20) // Indent text from left edge of card
                     
                     Spacer()
                     
                     if reserva.numPersonas == 1 {
                         Image(systemName: "person.fill")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 100, height: 100) // Adjust size as needed
                             .foregroundColor(.white)
                             .padding(.trailing, 20) // Indent icon from right edge of card
                         
                     } else if reserva.numPersonas == 2 {
                         Image(systemName: "person.2.fill")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 100, height: 100) // Adjust size as needed
                             .foregroundColor(.white)
                             .padding(.trailing, 20) // Indent icon from right edge of card
                     } else {
                         Image(systemName: "person.3.fill")
                             .resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 100, height: 100) // Adjust size as needed
                             .foregroundColor(.white)
                             .padding(.trailing, 20) // Indent icon from right edge of card
                     }
                 }
                 .padding(.top, 20) // Padding from top of card
                 .padding(.bottom, 50)
                 
                 Spacer()
                 
                 Text ("Tap para QR de reserva")
                         .font(.caption)
                         .foregroundColor(.white)
                         .frame(maxWidth: .infinity, alignment: .center) 
                         .padding(.bottom, 20)
                                  
             }
             .frame(maxWidth: .infinity, minHeight: 100, idealHeight: 295, maxHeight: 500) // Maintain height, allow width to adapt with padding
             .background(Color(red: 0.16, green: 0.44, blue: 0.59))
             .cornerRadius(20)
         }
    }
}

#Preview {
    let fechaInicio = Date().addingTimeInterval(10 * 60)
    let fechaFin = Date().addingTimeInterval(20 * 60)
    let calendar = Calendar.current
    let horaInicio = calendar.dateComponents([.hour, .minute], from: fechaInicio)
    let horaFin = calendar.dateComponents([.hour, .minute], from: fechaFin)

    return ReservaCard(reserva: Reserva(
        id: 1,
        estudianteId: 2,
        salaUbicacion: "Piso 1",
        salaNumero: 21,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        horaInicio: horaInicio,
        horaFin: horaFin,
        numPersonas: 2
    ))

}
