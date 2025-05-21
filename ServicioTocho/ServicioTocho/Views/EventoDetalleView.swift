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
    // Similar a como lo hicimos en EventosListView
    init(evento: Evento, authViewModel: AuthenticationViewModel) {
        self.evento = evento
        self.authViewModel = authViewModel

        // Configuración de la apariencia de la barra de navegación
        // Esto asegura que esta vista también siga el estilo si se presenta
        // o si la configuración global no se aplicó completamente.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground) // Color de fondo de la barra
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // Color del título (adaptable)
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label] // Color del título grande (adaptable)

        // Aplicar la apariencia
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal) // Color de los botones de la barra
    }

    var body: some View {
        ZStack { // ZStack para el color de fondo
            Color.appBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Título del Evento - Podríamos moverlo a la barra de navegación
                    // o mantenerlo aquí si preferimos un título grande en el contenido.
                    // Por ahora, lo dejo aquí como lo tenías.
                    Text(evento.nombre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary) // Usar color primario del sistema
                        .padding(.top)

                    // Mapa
                    Map(coordinateRegion: .constant(region), annotationItems: [evento]) { eventoItem in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: eventoItem.latitud, longitude: eventoItem.longitud), tint: Color.accentColorTeal) // Usar color de acento
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Sombra sutil

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
                    .background(Color(UIColor.secondarySystemGroupedBackground)) // Un fondo ligeramente diferente al de la tarjeta de lista para diferenciar
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)


                    // Tarjeta de Descripción
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.title3) // Un poco más grande para el título de sección
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primary)
                        Text(evento.descripcion)
                            .font(.body)
                            .foregroundColor(Color.secondary) // Color secundario para el cuerpo de la descripción
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
                            // Usar el color de acento para la acción principal "Unirme"
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
        .navigationTitle(evento.nombre) // El título se mostrará en la barra de navegación
        .navigationBarTitleDisplayMode(.inline) // O .large si prefieres
        .accentColor(Color.accentColorTeal) // Aplica el color de acento a los elementos de navegación (como el botón "Atrás")
        // El .onAppear puede permanecer para cualquier lógica específica de esta vista
    }

    func formatearFecha(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Un poco más descriptivo
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// La subvista InfoRow no necesita cambios, pero asegúrate de que su 'value' pueda manejar texto más largo.
struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) { // Menos espaciado interno
            Text(label)
                .font(.caption) // Más pequeño para la etiqueta
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .font(.callout) // Ligeramente más pequeño que .body pero legible
                .foregroundColor(.primary)
        }
        .padding(.vertical, 2) // Un poco de padding vertical para cada fila
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
            fechaInicio: Date().addingTimeInterval(3600*24*3), // En 3 días
            fechaFin: Date().addingTimeInterval(3600*24*3 + 3600*2), // Dura 2 horas
            ubicacionNombre: "Auditorio Municipal, Av. Revolución 123, Centro",
            latitud: 32.530,
            longitud: -117.042,
            organizador: "Ciudad Futura ONG",
            cupoMaximo: 150,
            horasLiberadas: 2
        )
        let mockAuthViewModel = AuthenticationViewModel()
        // Para simular que el usuario está registrado:
        // mockAuthViewModel.userProfile = UserProfile(id:"simulatedUser", nombreCompleto: "Usuario Preview", email: "preview@example.com", registeredEventIDs: [mockEventoPreview.id!])

        // Para ver el diseño aplicado, es importante que EventoDetalleView esté dentro de una NavigationView
        // ya que estamos configurando la apariencia de la barra de navegación.
        NavigationView {
            EventoDetalleView(evento: mockEventoPreview, authViewModel: mockAuthViewModel)
        }
        // Si tienes definida tu extensión de Color y los colores en Assets:
        // .environment(\.colorScheme, .light) // Para probar con light mode
        // .environment(\.colorScheme, .dark) // Para probar con dark mode
    }
}
