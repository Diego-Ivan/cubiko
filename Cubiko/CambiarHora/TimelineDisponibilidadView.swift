//
//  TimelineDisponibilidadView.swift
//  Cubiko
//
//  Created by Rafael on 21/04/26.
//

import SwiftUI

struct TimelineDisponibilidadView: View {

    @ObservedObject var vm: CambiarHoraViewModel

    private let slotMinutos: Double = 30
    private let slotsVisibles: Int  = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Etiquetas
            HStack(spacing: 0) {
                ForEach(slots, id: \.self) { slot in
                    Text(slot.formateadaHoraCorta())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Barra
            GeometryReader { geo in
                let totalMinutos = Double(slotsVisibles) * slotMinutos
                let anchoTotal   = geo.size.width

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemBackground))
                        .frame(height: 28)

                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                        .frame(height: 28)

                    if let rect = rectPara(
                        inicio: vm.horaEntrada,
                        fin: vm.horaSalida,
                        anchoTotal: anchoTotal,
                        totalMinutos: totalMinutos
                    ) {
                        let conflicto = vm.disponibilidad == .conflicto
                        RoundedRectangle(cornerRadius: 4)
                            .fill(conflicto ? Color.red.opacity(0.35) : Color.primaryCubiko)
                            .frame(width: rect.width, height: 28)
                            .offset(x: rect.minX)
                    }
                }
            }
            .frame(height: 28)

            // Leyenda
            HStack(spacing: 16) {
                LeyendaItem(color: Color(.systemBackground), borde: true, texto: "Disponible")
                LeyendaItem(color: Color.primaryCubiko,               texto: "Tu reserva")
                LeyendaItem(color: Color.red.opacity(0.35),               texto: "Conflicto")
            }
        }
    }

    private var slots: [Date] {
        let base = Calendar.current.date(
            bySetting: .minute,
            value: vm.horaEntrada.minuto < 30 ? 0 : 30,
            of: vm.horaEntrada
        ) ?? vm.horaEntrada

        return (0..<slotsVisibles).compactMap { i in
            Calendar.current.date(byAdding: .minute, value: Int(Double(i) * slotMinutos), to: base)
        }
    }

    private func rectPara(inicio: Date, fin: Date,
                          anchoTotal: CGFloat,
                          totalMinutos: Double) -> CGRect? {
        guard let base = slots.first, fin > inicio else { return nil }
        let offsetInicio = inicio.timeIntervalSince(base) / 60
        let duracion     = fin.timeIntervalSince(inicio) / 60
        let x = CGFloat(offsetInicio / totalMinutos) * anchoTotal
        let w = CGFloat(duracion     / totalMinutos) * anchoTotal
        return CGRect(x: max(x, 0), y: 0, width: min(w, anchoTotal - max(x, 0)), height: 28)
    }
}

// MARK: - Leyenda

struct LeyendaItem: View {
    let color: Color
    var borde: Bool = false
    let texto: String

    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .overlay(
                    borde ? RoundedRectangle(cornerRadius: 3)
                        .stroke(Color(.systemGray4), lineWidth: 1) : nil
                )
                .frame(width: 14, height: 14)
            Text(texto)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Date helpers

extension Date {
    var minuto: Int { Calendar.current.component(.minute, from: self) }

    func formateadaHoraCorta() -> String {
        let f = DateFormatter()
        f.locale     = Locale(identifier: "es_MX")
        f.dateFormat = "H:mm"
        return f.string(from: self)
    }
}
