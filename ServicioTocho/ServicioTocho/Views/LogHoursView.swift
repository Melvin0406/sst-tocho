//
//  LogHoursView.swift
//  ServicioTocho
//
//  Created by Kevin Brian on 5/21/25.
//

import SwiftUI

struct LogHoursView: View {
    let evento: Evento
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    @State private var horasReportadasStr: String = ""
    @State private var descripcionActividad: String = ""
    @State private var mostrarError: Bool = false
    @State private var mensajeError: String = ""

    // Inicializador para configurar la apariencia de la barra de navegación
    init(evento: Evento, authViewModel: AuthenticationViewModel) {
        self.evento = evento
        self.authViewModel = authViewModel

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
                    Text("Registrar Horas para:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(evento.nombre)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)

                    Divider()

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Horas Completadas")
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        TextField("Ej: 3.5", text: $horasReportadasStr)
                            .keyboardType(.decimalPad)
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Describe tu Actividad (Opcional)")
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        TextEditor(text: $descripcionActividad)
                            .frame(height: 150)
                            .padding(8)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }

                    if mostrarError {
                        Text(mensajeError)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .padding(.vertical, 5)
                    }

                    Button(action: submitHours) {
                        Text("Enviar Registro de Horas")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColorTeal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: Color.accentColorTeal.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .navigationTitle("Registrar Horas")
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(Color.accentColorTeal)
    }

    private func submitHours() {
        guard let horas = Double(horasReportadasStr), horas > 0 else {
            mensajeError = "Por favor, ingresa un número válido de horas (mayor a 0)."
            mostrarError = true
            return
        }

        guard let eventoID = evento.id, !eventoID.isEmpty else {
            mensajeError = "ID de evento inválido."
            mostrarError = true
            return
        }

        mostrarError = false // Limpiar error si todo está bien antes de enviar

        authViewModel.logHoursForEvent(
            eventoID: eventoID, // Pasamos solo el ID
            horas: horas,
            descripcion: descripcionActividad.isEmpty ? nil : descripcionActividad
        ) { success, error in
            if success {
                print("Horas registradas exitosamente para el evento: \(evento.nombre)")
                // La actualización de horas acumuladas y el posible cambio de estado del evento
                // se manejan en el ViewModel, y la UI debería reaccionar.
                dismiss() // Cierra la vista al completar
            } else {
                mensajeError = error ?? "Ocurrió un error al registrar las horas."
                mostrarError = true
            }
        }
    }
}

struct LogHoursView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // Necesario para la preview de una vista que usa .navigationTitle
            LogHoursView(
                evento: mockEventos.first ?? Evento(nombre: "Evento Vacío", descripcion: "", tipo: "", fechaInicio: Date(), fechaFin: Date(), ubicacionNombre: "", latitud: 0, longitud: 0, organizador: "", horasLiberadas: 0),
                authViewModel: AuthenticationViewModel()
            )
        }
    }
}
