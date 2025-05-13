//
//  EventoRowView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI

struct EventoRowView: View {
    let evento: Evento

    var body: some View {
        HStack {
            Image(systemName: iconoParaTipo(evento.tipo))
                .font(.title2)
                .frame(width: 40)
                .foregroundColor(colorParaTipo(evento.tipo))

            VStack(alignment: .leading) {
                Text(evento.nombre)
                    .font(.headline)
                Text(evento.tipo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Fecha: \(evento.fechaInicio, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }

    // Funciones helper para el icono y color según el tipo
    private func iconoParaTipo(_ tipo: String) -> String {
        switch tipo.lowercased() {
        case "ambiental":
            return "leaf.fill"
        case "social":
            return "heart.fill"
        case "educativo":
            return "book.fill"
        default:
            return "calendar.badge.exclamationmark"
        }
    }

    private func colorParaTipo(_ tipo: String) -> Color {
        switch tipo.lowercased() {
        case "ambiental":
            return .green
        case "social":
            return .pink
        case "educativo":
            return .blue
        default:
            return .orange
        }
    }
}

// Previsualización para EventoRowView
struct EventoRowView_Previews: PreviewProvider {
    static var previews: some View {
        // Usamos el primer evento de nuestros datos de ejemplo para la previsualización
        if !mockEventos.isEmpty {
            EventoRowView(evento: mockEventos[0])
                .previewLayout(.sizeThatFits) // Ajusta el tamaño de la previsualización al contenido
                .padding()
        } else {
            Text("No hay datos de ejemplo para previsualizar la fila.")
        }
    }
}
