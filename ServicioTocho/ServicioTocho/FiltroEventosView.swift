//
//  FiltroEventosView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct FiltroEventosView: View {
    @ObservedObject var filtro: EventoFiltro

    var body: some View {
        NavigationView {
            Form {
                Picker("Tipo", selection: $filtro.tipoSeleccionado) {
                    Text("Todos").tag("Todos")
                    Text("Ambiental").tag("Ambiental")
                    Text("Social").tag("Social")
                    Text("Educativo").tag("Educativo")
                }

                DatePicker("Desde", selection: $filtro.fechaDesde, displayedComponents: .date)
                DatePicker("Hasta", selection: $filtro.fechaHasta, displayedComponents: .date)

                TextField("Ubicación", text: $filtro.ubicacion)

                Toggle("Solo eventos unidos", isOn: $filtro.soloUnidos)
            }
            .navigationTitle("Filtrar Eventos")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aplicar") {
                        // Al cerrarse el sheet, los valores ya están actualizados
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}
