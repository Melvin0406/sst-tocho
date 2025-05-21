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

    var body: some View {
        NavigationView {
            Form {
                Picker("Tipo", selection: $filtro.tipoSeleccionado) {
                    ForEach(tiposDeEventosDisponibles, id: \.self) { tipo in
                        Text(tipo).tag(tipo)
                    }
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
                        dismiss()
                    }
                }
            }
        }
    }
}
