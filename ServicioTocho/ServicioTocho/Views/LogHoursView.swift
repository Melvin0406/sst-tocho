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

    init(evento: Evento, authViewModel: AuthenticationViewModel) {
        self.evento = evento
        self.authViewModel = authViewModel

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
                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(Color.accentColorTeal)
                            TextField("Ej: 3 ó 3.5", text: $horasReportadasStr)
                                .keyboardType(.decimalPad)
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        if let horasSugeridas = evento.horasLiberadas {
                            Text("Horas sugeridas por el evento: \(horasSugeridas)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.leading, 5)
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Describe tu Actividad (Opcional)")
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        TextEditor(text: $descripcionActividad)
                            .frame(height: 150)
                            .padding(8) // Padding interno para el TextEditor
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
                .onAppear {
                    if let horasSugeridasInt = evento.horasLiberadas {
                        // Convertimos el Int? a String para el TextField
                        self.horasReportadasStr = "\(horasSugeridasInt)"
                    } else {
                        // Si no hay horas sugeridas, podemos dejarlo vacío o poner "0"
                        self.horasReportadasStr = ""
                    }
                }
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

        mostrarError = false

        authViewModel.logHoursForEvent(
            eventoID: eventoID,
            horas: horas, 
            descripcion: descripcionActividad.isEmpty ? nil : descripcionActividad
        ) { success, error in
            if success {
                print("Horas registradas exitosamente para el evento: \(evento.nombre)")
                dismiss()
            } else {
                mensajeError = error ?? "Ocurrió un error al registrar las horas."
                mostrarError = true
            }
        }
    }
}
