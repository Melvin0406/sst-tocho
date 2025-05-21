//
//  FiltroEventosView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct FiltroEventosView: View {
    @ObservedObject var filtro: EventoFiltro
    let tiposDeEventosDisponibles: [String] // Asumo que esto se pasa desde EventosListView
    @Environment(\.dismiss) var dismiss

    // Inicializador para configurar la apariencia de la barra de navegación dentro de la sheet
    init(filtro: EventoFiltro, tiposDeEventosDisponibles: [String]) {
        self.filtro = filtro
        self.tiposDeEventosDisponibles = tiposDeEventosDisponibles

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground) // Mismo fondo que otras nav bars
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // Color de título adaptable
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        // Aplicar a la apariencia de la barra de navegación DENTRO de esta sheet
        // Esto es específico para la NavigationView de esta vista.
        // No afecta a UINavigationBar.appearance() globalmente aquí.
        // Sin embargo, si esta vista se reutilizara y no siempre tuviera su propia NavView,
        // el enfoque global de `UINavigationBar.appearance()` en la App o vista raíz sería más robusto.
        // Por ahora, para una sheet con su propia NavView, esto es local y está bien.
        // Si la configuración global ya está hecha, esto podría ser redundante o para asegurar el estilo.
        // Para sheets, es común tener que re-especificar o asegurar el estilo de la barra.
        // Vamos a mantenerlo por ahora para asegurar que la sheet tenga el estilo deseado.
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
                    .tint(Color.accentColorTeal) // Color del control del picker

                    DatePicker("Desde", selection: $filtro.fechaDesde, displayedComponents: .date)
                        .tint(Color.accentColorTeal) // Color del control del DatePicker

                    DatePicker("Hasta", selection: $filtro.fechaHasta, displayedComponents: .date)
                        .tint(Color.accentColorTeal)
                }

                Section(header: Text("Otros Filtros").foregroundColor(Color.accentColorTeal)) {
                    TextField("Ubicación (contiene)", text: $filtro.ubicacion)
                    Toggle("Mostrar solo eventos unidos", isOn: $filtro.soloUnidos)
                        .tint(Color.accentColorTeal) // Color del switch del Toggle
                }
            }
            // .background(Color.appBackground.opacity(0.5)) // Opcional: si quieres que el fondo del Form sea el mismo
            // .scrollContentBackground(.hidden) // Para que el fondo anterior se vea si se usa .background en Form
            .navigationTitle("Filtrar Eventos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        filtro.tipoSeleccionado = "Todos"
                        // Ajusta las fechas por defecto según tu lógica, quizás un rango más amplio o sin filtro de fecha por defecto
                        filtro.fechaDesde = Calendar.current.date(byAdding: .day, value: -365, to: Date()) ?? Date()
                        filtro.fechaHasta = Calendar.current.date(byAdding: .day, value: 365, to: Date()) ?? Date()
                        filtro.ubicacion = ""
                        filtro.soloUnidos = false
                    }
                    // .foregroundColor(Color.accentColorTeal) // El tintColor global debería manejar esto
                }
                ToolbarItem(placement: .navigationBarTrailing) { // Cambiado a .navigationBarTrailing para "Hecho"
                    Button("Hecho") { // Renombrado de "Aplicar"
                        // Ocultar el teclado antes de cerrar la vista
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        dismiss() // Cierra la sheet
                    }
                    // .foregroundColor(Color.accentColorTeal) // El tintColor global debería manejar esto
                }
            }
        }
        .accentColor(Color.accentColorTeal) // Establece el color de acento para esta vista y sus sub-vistas
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
