//
//  Evento.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI // O Foundation, si no necesitas nada específico de SwiftUI aquí
import CoreLocation // Para las coordenadas de ubicación

struct Evento: Identifiable, Codable { // Codable será útil para persistencia o API
    var id = UUID()
    var nombre: String
    var descripcion: String
    var tipo: String // Ejemplo: "Ambiental", "Social", "Educativo"
    var fechaInicio: Date
    var fechaFin: Date
    var ubicacionNombre: String
    var latitud: Double
    var longitud: Double
    var organizador: String // Opcional
    var cupoMaximo: Int? // Opcional
    // Podríamos añadir más adelante: var participantesInscritos: [String]? o [Usuario.ID]?

    // Para MapKit, podemos tener una propiedad computada para CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
}
