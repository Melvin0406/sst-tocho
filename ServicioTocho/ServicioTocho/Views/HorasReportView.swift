//
//  HorasReportView.swift
//  ServicioTocho
//
//  Created by Kevin Brian on 5/21/25.
//

import SwiftUI

struct HorasReportView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    let todosLosEventos: [Evento]

    @State private var mostrarShareSheet = false
    @State private var urlDelPDFCompartir: URL?
    @State private var isGeneratingPDF = false // Para el indicador de carga
    @State private var pdfErrorAlertMessage: String? = nil // Para mostrar alertas de error

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
    
    private func getEvento(byId eventoId: String?) -> Evento? {
        guard let eventoId = eventoId else { return nil }
        return todosLosEventos.first { $0.id == eventoId }
    }
    private func formatearFecha(_ date: Date, estilo: DateFormatter.Style = .long) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = estilo
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .center, spacing: 8) { Image(systemName: "scroll.fill").font(.system(size: 50)).foregroundColor(Color.accentColorTeal); Text("Reporte de Horas de Servicio Social").font(.title2).fontWeight(.bold).multilineTextAlignment(.center); Text("Emitido: \(formatearFecha(Date()))").font(.caption).foregroundColor(.secondary); }.frame(maxWidth: .infinity).padding(.vertical)
                    Divider()
                    VStack(alignment: .leading, spacing: 8) { Text("Estudiante:").font(.headline).foregroundColor(Color.accentColorTeal); Text(authViewModel.userProfile?.nombreCompleto ?? "N/A").font(.title3); Text("Correo: \(authViewModel.userProfile?.email ?? "N/A")").font(.subheadline).foregroundColor(.secondary); Text("Total de Horas Acumuladas: \(String(format: "%.1f", authViewModel.userProfile?.horasAcumuladas ?? 0.0)) horas").font(.headline).padding(.top, 5); }.padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(10).padding(.bottom)
                    Text("Detalle de Participaciones:").font(.headline).foregroundColor(Color.accentColorTeal)
                    if authViewModel.misRegistrosDeHoras.isEmpty { Text("No hay horas registradas para mostrar.").foregroundColor(.secondary).padding().frame(maxWidth: .infinity, alignment: .center);
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(authViewModel.misRegistrosDeHoras) { registro in
                                if let evento = getEvento(byId: registro.idEvento) {
                                    ParticipationDetailCard(evento: evento, registroHora: registro)
                                }
                            }
                        }
                    }
                    Spacer()
                }.padding()
            }
        }
        .navigationTitle("Reporte de Horas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { // Usamos Task para trabajo asíncrono
                        await generarYCompartirPDF()
                    }
                } label: {
                    if isGeneratingPDF {
                        ProgressView() // Muestra un spinner mientras se genera
                            .frame(width: 20, height: 20) // Ajusta el tamaño si es necesario
                    } else {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                .disabled(isGeneratingPDF) // Deshabilita el botón mientras se genera
            }
        }
        .sheet(isPresented: $mostrarShareSheet, onDismiss: limpiarArchivoTemporal) {
            // Se presenta la ShareSheet si urlDelPDFCompartir tiene un valor
            if let pdfURL = urlDelPDFCompartir {
                ShareSheet(activityItems: [pdfURL])
            } else {
                VStack {
                    Text("Preparando PDF...")
                    ProgressView()
                }
            }
        }
        .alert("Error al Generar PDF", isPresented: Binding<Bool>(
            get: { pdfErrorAlertMessage != nil },
            set: { if !$0 { pdfErrorAlertMessage = nil } } // Limpiar mensaje al cerrar
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(pdfErrorAlertMessage ?? "Ocurrió un error desconocido.")
        }
    }

    @MainActor
    private func generarYCompartirPDF() async {
        isGeneratingPDF = true
        pdfErrorAlertMessage = nil // Limpiar errores previos
        urlDelPDFCompartir = nil   // Limpiar URL previa

        guard let pdfData = authViewModel.generarReportePDFDatos(eventos: todosLosEventos) else {
            pdfErrorAlertMessage = "No se pudieron generar los datos del PDF. Asegúrate de tener horas registradas."
            print(pdfErrorAlertMessage!)
            isGeneratingPDF = false
            return
        }

        // Usar un nombre de archivo único cada vez
        let fileName = "Reporte_Horas_\(UUID().uuidString.prefix(8)).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try pdfData.write(to: tempURL)
            print("PDF generado y guardado en: \(tempURL)")
            urlDelPDFCompartir = tempURL // Establece la URL para la sheet
            mostrarShareSheet = true     // Muestra la sheet
        } catch {
            let errorMsg = "Error al guardar PDF temporal: \(error.localizedDescription)"
            print(errorMsg)
            pdfErrorAlertMessage = errorMsg
        }
        isGeneratingPDF = false
    }

    private func limpiarArchivoTemporal() {
        if let tempURL = urlDelPDFCompartir {
            do {
                try FileManager.default.removeItem(at: tempURL)
                print("Archivo PDF temporal eliminado: \(tempURL.lastPathComponent)")
            } catch {
                print("Error al eliminar archivo PDF temporal: \(error.localizedDescription)")
            }
            urlDelPDFCompartir = nil // Limpiar la URL después de usarla
        }
    }

    struct ParticipationDetailCard: View {
        let evento: Evento
        let registroHora: RegistroHora
        private func formatearFecha(_ date: Date, estilo: DateFormatter.Style = .medium) -> String { let formatter = DateFormatter(); formatter.dateStyle = estilo; formatter.timeStyle = .short; return formatter.string(from: date) }
        var body: some View { VStack(alignment: .leading, spacing: 8) { Text(evento.nombre).font(.title3).fontWeight(.semibold).foregroundColor(Color.accentColorTeal); HStack { Image(systemName: "calendar"); Text("Fecha del Evento: \(formatearFecha(evento.fechaInicio))") }.font(.caption).foregroundColor(.secondary); HStack { Image(systemName: "hourglass"); Text("Horas Reportadas: \(String(format: "%.1f", registroHora.horasReportadas))") }.font(.subheadline); if let descripcion = registroHora.descripcionActividad, !descripcion.isEmpty { VStack(alignment: .leading) { Text("Actividad Realizada:").font(.caption).foregroundColor(.secondary); Text(descripcion).font(.footnote); }.padding(.top, 4); }; HStack { Image(systemName: "checkmark.seal.fill"); Text("Estado: Aprobado") }.font(.caption).foregroundColor(.green).padding(.top, 2); }.padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(10).shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1) }
    }
}



struct ShareSheet: UIViewControllerRepresentable { 
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController { let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities); return controller; }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
