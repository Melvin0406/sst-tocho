//
//  EventoFiltro.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import Foundation
import SwiftUI

class EventoFiltro: ObservableObject {
    @Published var tipoSeleccionado: String = "Todos"
    @Published var fechaDesde: Date = Date()
    @Published var fechaHasta: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    @Published var ubicacion: String = ""
    @Published var soloUnidos: Bool = false
}
