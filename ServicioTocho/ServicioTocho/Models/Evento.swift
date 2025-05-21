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
    var organizador: String?
    var cupoMaximo: Int?
    var horasLiberadas: Int?
    
        init(id: String? = nil, nombre: String, descripcion: String, tipo: String, fechaInicio: Date, fechaFin: Date, ubicacionNombre: String, latitud: Double, longitud: Double, organizador: String, cupoMaximo: Int? = nil, horasLiberadas: Int? = nil) {
            self.id = id
            self.nombre = nombre
            self.descripcion = descripcion
            self.tipo = tipo
            self.fechaInicio = fechaInicio
            self.fechaFin = fechaFin
            self.ubicacionNombre = ubicacionNombre
            self.latitud = latitud
            self.longitud = longitud
            self.organizador = organizador
            self.cupoMaximo = cupoMaximo
            self.horasLiberadas = horasLiberadas
        }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitud, longitude: longitud)
    }
}
