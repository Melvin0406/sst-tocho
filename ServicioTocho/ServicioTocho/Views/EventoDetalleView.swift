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

    // Propiedad computada para verificar si el usuario ya está unido
    private var isUserRegistered: Bool {
        // 1. Asegurarnos de que evento.id (String?) no sea nil y no esté vacío
        guard let validEventID = evento.id, !validEventID.isEmpty else {
            return false // No se puede estar registrado a un evento sin un ID válido
        }
        // 2. Llamar a la función del ViewModel con el String válido
        return authViewModel.isUserRegisteredForEvent(eventID: validEventID)
    }

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
                Map(coordinateRegion: .constant(region), annotationItems: [evento]) { eventoItem in
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: eventoItem.latitud, longitude: eventoItem.longitud), tint: .blue)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)

                // Información general
                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(label: "Organizador", value: evento.organizador) // Asumiendo que 'organizador' en tu struct Evento es String y no String?
                                                                            // Si es String?, entonces evento.organizador ?? "No especificado"
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

                // Botón de Unirse/Cancelar Registro
                Button(action: {
                    // 1. Asegurarnos de que evento.id (String?) no sea nil y no esté vacío ANTES de la acción
                    guard let validEventID = evento.id, !validEventID.isEmpty else {
                        print("Error: ID de evento inválido. No se puede (des)registrar.")
                        // Opcionalmente, mostrar una alerta al usuario
                        return
                    }

                    // 2. Usar el validEventID (String) para las funciones del ViewModel
                    if isUserRegistered { // isUserRegistered ya usa la lógica correcta con validEventID
                        authViewModel.unregisterUserFromEvent(eventID: validEventID)
                    } else {
                        authViewModel.registerUserForEvent(eventID: validEventID)
                    }
                }) {
                    Text(isUserRegistered ? "Cancelar Registro" : "Unirme al Evento")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isUserRegistered ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .navigationTitle(evento.nombre)
        .navigationBarTitleDisplayMode(.inline)
        // El .onAppear que tenías antes puede permanecer si lo necesitas
    }

    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Subvista para fila de información (sin cambios)
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

// MARK: - Preview (sin cambios respecto a la corrección anterior)
struct EventoDetalleView_Previews: PreviewProvider {
    static var previews: some View {
        let mockEventoPreview = Evento(
            id: "previewEvento123", // Ahora un String para el ID de @DocumentID
            nombre: "Evento de Prueba Detalle",
            descripcion: "Esta es una descripción larga y detallada del evento de prueba.",
            tipo: "Social",
            fechaInicio: Date(),
            fechaFin: Date().addingTimeInterval(3600*2),
            ubicacionNombre: "Lugar de Prueba, Calle Falsa 123",
            latitud: 32.537,
            longitud: -117.011,
            organizador: "ONG Ejemplo", // Tu struct tiene organizador como String, no String?
            cupoMaximo: 30,
            horasLiberadas: 5
        )
        let mockAuthViewModel = AuthenticationViewModel()
        // Para simular que el usuario está registrado en la preview:
        // mockAuthViewModel.userProfile = UserProfile(id: "testUID", username: "TestUser", email: "test@example.com", registeredEventIDs: ["previewEvento123"])

        NavigationView {
            EventoDetalleView(evento: mockEventoPreview, authViewModel: mockAuthViewModel)
        }
    }
}
