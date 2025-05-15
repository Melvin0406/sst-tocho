//
//  SwiftUIView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import Foundation // Necesitamos Foundation para Date
import CoreLocation // Para las coordenadas

// Datos de ejemplo para Eventos
let mockEventos: [Evento] = [
    Evento(
        nombre: "Limpieza de Playa Costa Azul",
        descripcion: "Únete a nosotros para limpiar la playa Costa Azul y proteger nuestro ecosistema marino. Proporcionaremos bolsas y guantes.",
        tipo: "Ambiental",
        fechaInicio: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, // Dentro de 7 días
        fechaFin: Calendar.current.date(byAdding: .day, value: 7, to: Date())!.addingTimeInterval(3600*3), // Dura 3 horas
        ubicacionNombre: "Playa Costa Azul, Ensenada",
        latitud: 31.8639, // Coordenadas de ejemplo
        longitud: -116.6067,
        organizador: "ONG Mar Limpio",
        cupoMaximo: 50,
        horasLiberadas: 10
    ),
    Evento(
        nombre: "Colecta de Alimentos No Perecederos",
        descripcion: "Ayuda a recolectar alimentos para familias necesitadas en la comunidad. Se aceptan donaciones en el centro comunitario.",
        tipo: "Social",
        fechaInicio: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
        fechaFin: Calendar.current.date(byAdding: .day, value: 10, to: Date())!.addingTimeInterval(3600*4),
        ubicacionNombre: "Centro Comunitario El Sol",
        latitud: 32.5029, // Coordenadas de ejemplo para Tijuana
        longitud: -116.9732,
        organizador: "Fundación Ayuda Local",
        cupoMaximo: nil, // Sin cupo máximo
        horasLiberadas: 20
    ),
    Evento(
        nombre: "Taller de Lectura para Niños",
        descripcion: "Participa como voluntario leyendo cuentos y organizando actividades lúdicas para niños de primaria.",
        tipo: "Educativo",
        fechaInicio: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
        fechaFin: Calendar.current.date(byAdding: .month, value: 1, to: Date())!.addingTimeInterval(3600*2),
        ubicacionNombre: "Biblioteca Pública Benito Juárez",
        latitud: 32.5271, // Coordenadas de ejemplo para Tijuana
        longitud: -117.0201,
        organizador: "Amigos de la Biblioteca",
        cupoMaximo: 20,
        horasLiberadas: 30
    ),
    Evento(
        nombre: "Reforestación Parque Morelos",
        descripcion: "Planta árboles y contribuye a la mejora del pulmón más grande de la ciudad. Herramientas y árboles proporcionados.",
        tipo: "Ambiental",
        fechaInicio: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
        fechaFin: Calendar.current.date(byAdding: .day, value: 20, to: Date())!.addingTimeInterval(3600*5),
        ubicacionNombre: "Parque Morelos, Tijuana",
        latitud: 32.4858,
        longitud: -116.9300,
        organizador: "Ciudad Verde AC",
        cupoMaximo: 100,
        horasLiberadas: 20
    )
]
