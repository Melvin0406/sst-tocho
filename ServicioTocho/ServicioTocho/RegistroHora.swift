//
//  RegistroHora.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//


import Foundation

struct RegistroHora: Identifiable, Codable {
    var id = UUID()
    var idEvento: Evento.ID // Necesitará que Evento.swift exista y esté correcto
    var idUsuario: Usuario.ID // Necesitará que Usuario.swift exista y esté correcto
    var fecha: Date
    var horasReportadas: Double
    var aprobado: Bool = false // Para la validación por parte de un administrador
    var descripcionActividad: String? // Opcional, para que el estudiante detalle qué hizo
}