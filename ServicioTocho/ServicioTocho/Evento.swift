//
//  Evento.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import FirebaseFirestore
import CoreLocation

struct Evento: Identifiable, Codable {
    @DocumentID var id: String? // El ID del documento de Firestore
    var nombre: String
    var descripcion: String
    var tipo: String
    var fechaInicio: Date
    var fechaFin: Date
    var ubicacionNombre: String
    var latitud: Double
    var longitud: Double
    var organizador: String
    var cupoMaximo: Int?
    var horasLiberadas: Int?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
}
