//
//  HorasReportView.swift
//  ServicioTocho
//
//  Created by Kevin Brian on 5/21/25.
//

import SwiftUI

struct HorasReportView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    let todosLosEventos: [Evento] // Para buscar nombres de eventos

    // Helper para obtener el Evento dado un ID
    private func getEvento(byId eventoId: String?) -> Evento? {
        guard let eventoId = eventoId else { return nil }
        return todosLosEventos.first { $0.id == eventoId }
    }

    // Formateador de fecha
    private func formatearFecha(_ date: Date, estilo: DateFormatter.Style = .long) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = estilo
        formatter.timeStyle = .none // No mostramos la hora en el reporte, usualmente
        return formatter.string(from: date)
    }

    // Inicializador para la apariencia de la barra de navegación
    init(authViewModel: AuthenticationViewModel, todosLosEventos: [Evento]) {
        self.authViewModel = authViewModel
        self.todosLosEventos = todosLosEventos

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
                    // Encabezado del Reporte
                    VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "scroll.fill") // Icono de certificado/reporte
                            .font(.system(size: 50))
                            .foregroundColor(Color.accentColorTeal)
                        Text("Reporte de Horas de Servicio Social")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text("Emitido: \(formatearFecha(Date()))") // Fecha actual
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)

                    Divider()

                    // Información del Estudiante
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estudiante:")
                            .font(.headline)
                            .foregroundColor(Color.accentColorTeal)
                        Text(authViewModel.userProfile?.nombreCompleto ?? "N/A")
                            .font(.title3)
                        Text("Correo: \(authViewModel.userProfile?.email ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Total de Horas Acumuladas: \(String(format: "%.1f", authViewModel.userProfile?.horasAcumuladas ?? 0.0)) horas")
                            .font(.headline)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.bottom)

                    // Detalle de Participaciones
                    Text("Detalle de Participaciones:")
                        .font(.headline)
                        .foregroundColor(Color.accentColorTeal)

                    if authViewModel.misRegistrosDeHoras.isEmpty {
                        Text("No hay horas registradas para mostrar.")
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Usamos un VStack en lugar de List para un formato más de "documento"
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(authViewModel.misRegistrosDeHoras) { registro in
                                if let evento = getEvento(byId: registro.idEvento) {
                                    ParticipationDetailCard(evento: evento, registroHora: registro)
                                }
                            }
                        }
                    }
                    Spacer() // Para empujar contenido hacia arriba
                }
                .padding()
            }
        }
        .navigationTitle("Reporte de Horas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Subvista para cada participación detallada
struct ParticipationDetailCard: View {
    let evento: Evento
    let registroHora: RegistroHora

    private func formatearFecha(_ date: Date, estilo: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = estilo
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(evento.nombre)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Color.accentColorTeal)

            HStack {
                Image(systemName: "calendar")
                Text("Fecha del Evento: \(formatearFecha(evento.fechaInicio))")
            }.font(.caption).foregroundColor(.secondary)

            HStack {
                Image(systemName: "hourglass")
                Text("Horas Reportadas: \(String(format: "%.1f", registroHora.horasReportadas))")
            }.font(.subheadline)

            if let descripcion = registroHora.descripcionActividad, !descripcion.isEmpty {
                VStack(alignment: .leading) {
                    Text("Actividad Realizada:")
                        .font(.caption).foregroundColor(.secondary)
                    Text(descripcion)
                        .font(.footnote)
                }
                .padding(.top, 4)
            }

            // El estado "Aprobado" siempre será true por ahora
            HStack {
                Image(systemName: "checkmark.seal.fill")
                Text("Estado: Aprobado")
            }
            .font(.caption)
            .foregroundColor(.green)
            .padding(.top, 2)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
