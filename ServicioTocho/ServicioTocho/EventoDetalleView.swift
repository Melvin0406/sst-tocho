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
    // Se elimina @Binding var eventosUnidos: Set<UUID>
    // Se añade el ViewModel para manejar la lógica de registro
    @ObservedObject var authViewModel: AuthenticationViewModel

    // Propiedad computada para verificar si el usuario ya está unido, usando el ViewModel
    var isUserRegistered: Bool {
        // Asegúrate de que tu Evento.id sea un String o puedas convertirlo a String.
        // Si Evento.id es UUID, usamos evento.id.uuidString.
        authViewModel.isUserRegisteredForEvent(eventID: evento.id.uuidString)
    }

    // La región del mapa puede seguir como la tenías
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
                    // Usamos eventoItem aquí, que es el 'evento' de la clausura, para asegurar la conformidad con Identifiable
                    MapMarker(coordinate: CLLocationCoordinate2D(latitude: eventoItem.latitud, longitude: eventoItem.longitud), tint: .blue)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)

                // Información general en una sola tarjeta
                VStack(alignment: .leading, spacing: 10) {
                    // Asumiendo que 'organizador' puede ser nil, usamos el operador ??
                    InfoRow(label: "Organizador", value: evento.organizador ?? "No especificado")
                    // Asumiendo que 'horasLiberadas' es una propiedad en tu struct Evento
                    // y que es un Double opcional. Si es diferente, ajusta esto.
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

                // Botón para unirse/cancelar registro, ahora usando authViewModel
                Button(action: {
                    if isUserRegistered {
                        authViewModel.unregisterUserFromEvent(eventID: evento.id.uuidString)
                    } else {
                        authViewModel.registerUserForEvent(eventID: evento.id.uuidString)
                    }
                }) {
                    Text(isUserRegistered ? "Cancelar Registro" : "Unirme al Evento")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isUserRegistered ? Color.red : Color.blue) // Cambiado el color para "Cancelar"
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .navigationTitle(evento.nombre) // Es bueno tener un título para la barra de navegación
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Opcional: Si quieres asegurarte de que el perfil esté cargado
            // aunque el init de AuthViewModel ya debería manejarlo.
            // if authViewModel.userProfile == nil, let uid = authViewModel.currentUser()?.uid {
            //     authViewModel.fetchUserProfile(uid: uid)
            // }
        }
    }

    // Función para formatear las fechas (la mantengo como la tenías)
    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Subvista para fila de información (la mantengo como la tenías)
struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .fontWeight(.semibold)
                .frame(width: 120, alignment: .leading) // Ajusta el ancho si es necesario
                .foregroundColor(.secondary)
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct EventoDetalleView_Previews: PreviewProvider {
    static var previews: some View {
        // Necesitas un evento de ejemplo y un authViewModel para la preview
        let mockEventoPreview = Evento( // Renombrado para evitar colisión con el parámetro de la vista
            id: UUID(), // Asegúrate de que tu struct Evento tenga un id si no lo tiene por defecto
            nombre: "Evento de Prueba Detalle",
            descripcion: "Esta es una descripción larga y detallada del evento de prueba.",
            tipo: "Social",
            fechaInicio: Date(),
            fechaFin: Date().addingTimeInterval(3600*2),
            ubicacionNombre: "Lugar de Prueba, Calle Falsa 123",
            latitud: 32.537,
            longitud: -117.011,
            organizador: "ONG Ejemplo"
            cupoMaximo: 30,
            horasLiberadas: 5
        )
        let mockAuthViewModel = AuthenticationViewModel()
        // Para simular diferentes estados en la preview:
        // 1. Usuario no registrado: mockAuthViewModel.userProfile = UserProfile(id: "testUID", username: "Test", email: "test@test.com", registeredEventIDs: [])
        // 2. Usuario registrado: mockAuthViewModel.userProfile = UserProfile(id: "testUID", username: "Test", email: "test@test.com", registeredEventIDs: [mockEventoPreview.id.uuidString])

        NavigationView {
            EventoDetalleView(evento: mockEventoPreview, authViewModel: mockAuthViewModel)
        }
    }
}
