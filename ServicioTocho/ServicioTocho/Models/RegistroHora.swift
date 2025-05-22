//
//  RegistroHora.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//


import Foundation

struct RegistroHora: Identifiable, Codable {
    var id = UUID()
    var idEvento: String?
    var idUsuario: String?
    var fecha: Date
    var horasReportadas: Double
    var aprobado: Bool = false
    var descripcionActividad: String? 
}
