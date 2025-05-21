//
//  Usuario.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//


import SwiftUI // O Foundation

struct Usuario: Identifiable, Codable {
    var id = UUID() // O podrías usar un ID de estudiante si es único y lo provee la escuela
    var nombreCompleto: String
    var correoElectronico: String
    var horasAcumuladas: Double = 0.0
    // Más adelante: var eventosRegistrados: [Evento.ID]?
    // Más adelante: var certificados: [Certificado.ID]?
}