//
//  Usuario.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//


import SwiftUI 

struct Usuario: Identifiable, Codable {
    var id = UUID()
    var nombreCompleto: String
    var correoElectronico: String
    var horasAcumuladas: Double = 0.0
}
