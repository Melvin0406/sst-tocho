//
//  FiltroEventosView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct FiltroEventosView: View {
    @ObservedObject var filtro: EventoFiltro
    let tiposDeEventosDisponibles: [String]
    @Environment(\.dismiss) var dismiss

    
    init(filtro: EventoFiltro, tiposDeEventosDisponibles: [String]) {
        self.filtro = filtro
        self.tiposDeEventosDisponibles = tiposDeEventosDisponibles

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Filtros Principales").foregroundColor(Color.accentColorTeal)) {
                    Picker("Tipo de Evento", selection: $filtro.tipoSeleccionado) {
                        ForEach(tiposDeEventosDisponibles, id: \.self) { tipo in
                            Text(tipo).tag(tipo)
                        }
                    }
                    .tint(Color.accentColorTeal)

                    DatePicker("Desde", selection: $filtro.fechaDesde, displayedComponents: .date)
                        .tint(Color.accentColorTeal)

                    DatePicker("Hasta", selection: $filtro.fechaHasta, displayedComponents: .date)
                        .tint(Color.accentColorTeal)
                }

                Section(header: Text("Otros Filtros").foregroundColor(Color.accentColorTeal)) {
                    TextField("Ubicación (contiene)", text: $filtro.ubicacion)
                    Toggle("Mostrar solo eventos unidos", isOn: $filtro.soloUnidos)
                        .tint(Color.accentColorTeal)
                }
            }
            
            .navigationTitle("Filtrar Eventos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        filtro.tipoSeleccionado = "Todos"
                        filtro.fechaDesde = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
                        filtro.fechaHasta = Calendar.current.date(byAdding: .day, value: 365, to: Date()) ?? Date()
                        filtro.ubicacion = ""
                        filtro.soloUnidos = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Hecho") {
                        // Ocultar el teclado antes de cerrar la vista
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        dismiss() // Cierra la sheet
                    }
                }
            }
        }
        .accentColor(Color.accentColorTeal) 
    }
}

// Preview
struct FiltroEventosView_Previews: PreviewProvider {
    static var previews: some View {
        // Datos de ejemplo para la preview
        let ejemploTipos = ["Todos", "Ambiental", "Social", "Educativo", "Comunitario"]
        FiltroEventosView(filtro: EventoFiltro(), tiposDeEventosDisponibles: ejemploTipos)
    }
}
