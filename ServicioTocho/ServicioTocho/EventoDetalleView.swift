//
//  EventoDetalle.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//
import SwiftUI
import MapKit

struct EventoDetalleView: View {
    let evento: Evento
    @State private var unido = false

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: evento.latitud, longitude: evento.longitud),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Título
                Text(evento.nombre)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                // Mapa
                Map(coordinateRegion: .constant(region), annotationItems: [evento]) { evento in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: evento.latitud, longitude: evento.longitud), tint: .blue)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)

                // Información general en una sola tarjeta
                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(label: "Organizador", value: evento.organizador)
                    InfoRow(label: "Tipo", value: evento.tipo)
                    InfoRow(label: "Ubicación", value: evento.ubicacionNombre)
                    InfoRow(label: "Inicio", value: formatearFecha(evento.fechaInicio))
                    InfoRow(label: "Fin", value: formatearFecha(evento.fechaFin))
                    if let cupo = evento.cupoMaximo {
                        InfoRow(label: "Cupo máximo", value: "\(cupo) personas")
                    } else {
                        InfoRow(label: "Cupo", value: "Ilimitado")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Descripción
                VStack(alignment: .leading, spacing: 8) {
                    Text("Descripción")
                        .font(.headline)
                    Text(evento.descripcion)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Botón para unirse
                Button(action: {
                    unido.toggle()
                }) {
                    Text(unido ? "Ya estás unido" : "Unirse al evento")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(unido ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Subvista para fila de información
struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .fontWeight(.semibold)
                .frame(width: 120, alignment: .leading)
                .foregroundColor(.secondary)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct EventoDetalleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventoDetalleView(evento: mockEventos[0])
        }
    }
}
