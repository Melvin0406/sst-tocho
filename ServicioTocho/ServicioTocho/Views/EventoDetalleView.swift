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
    @ObservedObject var authViewModel: AuthenticationViewModel

    private var isUserRegistered: Bool {
        guard let validEventID = evento.id, !validEventID.isEmpty else {
            return false
        }
        return authViewModel.isUserRegisteredForEvent(eventID: validEventID)
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: evento.latitud, longitude: evento.longitud),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    // Inicializador para configurar la apariencia de la barra de navegación
    init(evento: Evento, authViewModel: AuthenticationViewModel) {
        self.evento = evento
        self.authViewModel = authViewModel

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        // Aplicar la apariencia
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal)
    }

    var body: some View {
        ZStack { // ZStack para el color de fondo
            Color.appBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(evento.nombre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .padding(.top)

                    // Mapa
                    Map(coordinateRegion: .constant(region), annotationItems: [evento]) { eventoItem in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: eventoItem.latitud, longitude: eventoItem.longitud), tint: Color.accentColorTeal)
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)

                    // Tarjeta de Información General
                    VStack(alignment: .leading, spacing: 10) {
                        InfoRow(label: "Organizador", value: evento.organizador ?? "No definido")
                        InfoRow(label: "Horas a liberar", value: evento.horasLiberadas?.description ?? "N/A")
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
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)


                    // Tarjeta de Descripción
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primary)
                        Text(evento.descripcion)
                            .font(.body)
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)


                    // Botón de Unirse/Cancelar Registro
                    Button(action: {
                        guard let validEventID = evento.id, !validEventID.isEmpty else {
                            print("Error: ID de evento inválido. No se puede (des)registrar.")
                            return
                        }
                        if isUserRegistered {
                            authViewModel.unregisterUserFromEvent(eventID: validEventID)
                        } else {
                            authViewModel.registerUserForEvent(eventID: validEventID)
                        }
                    }) {
                        Text(isUserRegistered ? "Cancelar Registro" : "Unirme al Evento")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isUserRegistered ? Color.red : Color.accentColorTeal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(evento.nombre)
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(Color.accentColorTeal)
    }

    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .font(.callout)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2)
    }
}

// Preview
struct EventoDetalleView_Previews: PreviewProvider {
    static var previews: some View {
        let mockEventoPreview = Evento(
            id: "previewEvento123",
            nombre: "Conferencia sobre Sostenibilidad Urbana",
            descripcion: "Una charla inspiradora sobre cómo podemos contribuir a crear ciudades más verdes y sostenibles para el futuro. Contaremos con expertos en urbanismo y ecología.",
            tipo: "Educativo",
            fechaInicio: Date().addingTimeInterval(3600*24*3),
            fechaFin: Date().addingTimeInterval(3600*24*3 + 3600*2),
            ubicacionNombre: "Auditorio Municipal, Av. Revolución 123, Centro",
            latitud: 32.530,
            longitud: -117.042,
            organizador: "Ciudad Futura ONG",
            cupoMaximo: 150,
            horasLiberadas: 2
        )
        let mockAuthViewModel = AuthenticationViewModel()
        
        NavigationView {
            EventoDetalleView(evento: mockEventoPreview, authViewModel: mockAuthViewModel)
        }
    }
}
