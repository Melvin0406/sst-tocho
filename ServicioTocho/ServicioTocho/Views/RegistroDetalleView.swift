//
//  RegistroDetalleView.swift
//  ServicioTocho
//
//  Created by Kevin Brian on 5/21/25.
//

import SwiftUI

struct RegistroDetalleView: View {
    let registroHora: RegistroHora
    let evento: Evento // El evento asociado a este registro de horas

    // Inicializador para configurar la apariencia de la barra de navegación
    init(registroHora: RegistroHora, evento: Evento) {
        self.registroHora = registroHora
        self.evento = evento

        // Configuración de la apariencia de la barra de navegación
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal)
    }

    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Detalle de Participación")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(evento.nombre)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)

                    Divider()

                    // Tarjeta de Detalles del Registro
                    VStack(alignment: .leading, spacing: 15) {
                        DetailRow(iconName: "calendar.badge.clock", label: "Fecha de Registro de Horas", value: formatearFecha(registroHora.fecha))
                        DetailRow(iconName: "hourglass.bottomhalf.fill", label: "Horas Reportadas", value: String(format: "%.1f", registroHora.horasReportadas))

                        if let descripcion = registroHora.descripcionActividad, !descripcion.isEmpty {
                            DetailRow(iconName: "text.bubble.fill", label: "Descripción de Actividad", value: descripcion)
                        } else {
                            DetailRow(iconName: "text.bubble", label: "Descripción de Actividad", value: "No se proporcionó descripción.")
                        }

                        DetailRow(iconName: registroHora.aprobado ? "checkmark.seal.fill" : "xmark.seal.fill",
                                  label: "Estado de Aprobación",
                                  value: registroHora.aprobado ? "Aprobado" : "Pendiente/Rechazado") // Como es auto-aprobado, siempre será "Aprobado"
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

                    // Podrías añadir más información del evento aquí si es necesario,
                    // aunque el foco es el registro de horas.

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Registro de Horas")
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

struct RegistroDetalleView_Previews: PreviewProvider {
    static var previews: some View {
        let mockEvento = mockEventos.first ?? Evento(id: "ev1", nombre: "Evento de Muestra", descripcion: "", tipo: "", fechaInicio: Date(), fechaFin: Date(), ubicacionNombre: "", latitud: 0, longitud: 0, organizador: "", horasLiberadas: 0)
        let mockRegistro = RegistroHora(
            idEvento: mockEvento.id,
            idUsuario: "user123",
            fecha: Date(),
            horasReportadas: 4.5,
            aprobado: true,
            descripcionActividad: "Ayudé con la logística y la recepción de los asistentes. Fue una gran experiencia y aprendí mucho sobre la organización de eventos comunitarios."
        )
        NavigationView {
            RegistroDetalleView(registroHora: mockRegistro, evento: mockEvento)
        }
    }
}
