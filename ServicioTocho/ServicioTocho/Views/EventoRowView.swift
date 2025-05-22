//
//  EventoRowView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI

struct EventoRowView: View {
    let evento: Evento
    @ObservedObject var authViewModel: AuthenticationViewModel

    private var isUserRegistered: Bool {
        guard let eventID = evento.id, !eventID.isEmpty else { return false }
        return authViewModel.isUserRegisteredForEvent(eventID: eventID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(evento.tipo)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colorParaTipo(evento.tipo).opacity(0.8))
                        .clipShape(Capsule())
                    
                    Text(evento.nombre)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
                Spacer()
                Image(systemName: iconoParaTipo(evento.tipo))
                    .font(.largeTitle)
                    .foregroundColor(colorParaTipo(evento.tipo))
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 8)

            Divider().padding(.horizontal)

            // Sección de Detalles (Fecha y Ubicación)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                    Text("\(evento.fechaInicio, style: .date), \(evento.fechaInicio, style: .time)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.secondary)
                    Text(evento.ubicacionNombre)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding([.horizontal, .bottom])
            .padding(.top, 8)
            
            // Indicador de si está unido
            if isUserRegistered {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Unido")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // Funciones helper
    private func iconoParaTipo(_ tipo: String) -> String {
        switch tipo.lowercased() {
        case "ambiental": return "leaf.arrow.triangle.circlepath" 
        case "social": return "heart.text.square.fill"
        case "educativo": return "books.vertical.fill"
        case "comunitario": return "person.3.sequence.fill"
        default: return "sparkles"
        }
    }

    private func colorParaTipo(_ tipo: String) -> Color {
        switch tipo.lowercased() {
        case "ambiental": return .green
        case "social": return .pink
        case "educativo": return .blue
        case "comunitario": return .purple
        default: return .orange
        }
    }
}
