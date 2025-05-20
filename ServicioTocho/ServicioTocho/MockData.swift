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
    ),
    Evento(
            nombre: "Apoyo en Albergue para Migrantes",
            descripcion: "Colabora en la organización y distribución de recursos en un albergue que apoya a migrantes en la ciudad.",
            tipo: "Social",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 15, to: Date())!.addingTimeInterval(3600*6),
            ubicacionNombre: "Albergue El Refugio, Tijuana",
            latitud: 32.5680,
            longitud: -117.0520,
            organizador: "Organización Esperanza",
            cupoMaximo: 30,
            horasLiberadas: 25
    ),
        Evento(
            nombre: "Taller de Reciclaje Creativo",
            descripcion: "Enseña a reutilizar materiales reciclados para crear objetos útiles y artísticos.",
            tipo: "Ambiental",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 2, to: Date())!.addingTimeInterval(3600*3),
            ubicacionNombre: "Centro Cultural Comunitario Otay",
            latitud: 32.5910,
            longitud: -116.9380,
            organizador: "Recicla y Crea",
            cupoMaximo: 25,
            horasLiberadas: 15
    ),
        Evento(
            nombre: "Acompañamiento a Adultos Mayores",
            descripcion: "Brinda compañía y apoyo a adultos mayores en una residencia a través de actividades recreativas y conversaciones.",
            tipo: "Social",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 25, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 25, to: Date())!.addingTimeInterval(3600*2),
            ubicacionNombre: "Residencia Geriátrica La Paz",
            latitud: 32.4512,
            longitud: -116.9015,
            organizador: "Voluntarios por la Vejez",
            cupoMaximo: 12,
            horasLiberadas: 18
    ),
        Evento(
            nombre: "Clases de Alfabetización para Adultos",
            descripcion: "Ayuda a personas adultas a aprender a leer y escribir, abriendo nuevas oportunidades para ellos.",
            tipo: "Educativo",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 1, to: Date())!.addingTimeInterval(3600*2),
            ubicacionNombre: "Salón Comunal Mariano Matamoros",
            latitud: 32.6105,
            longitud: -116.8950,
            organizador: "INAEBA Tijuana",
            cupoMaximo: 15,
            horasLiberadas: 35
    ),
        Evento(
            nombre: "Jornada de Limpieza de Arroyo",
            descripcion: "Participa en la limpieza de un arroyo local para prevenir la contaminación y mejorar el entorno natural.",
            tipo: "Ambiental",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 18, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 18, to: Date())!.addingTimeInterval(3600*4),
            ubicacionNombre: "Arroyo Alamar, Tijuana",
            latitud: 32.5820,
            longitud: -116.9700,
            organizador: "Agua Limpia para Todos",
            cupoMaximo: 40,
            horasLiberadas: 16
    ),
        Evento(
            nombre: "Apoyo en Evento de Donación de Sangre",
            descripcion: "Colabora en la logística y recepción de donantes en una campaña de donación de sangre.",
            tipo: "Salud",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 22, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 22, to: Date())!.addingTimeInterval(3600*5),
            ubicacionNombre: "Hospital General de Tijuana",
            latitud: 32.5295,
            longitud: -117.0050,
            organizador: "Cruz Roja Mexicana",
            cupoMaximo: 20,
            horasLiberadas: 20
    ),
        Evento(
            nombre: "Taller de Habilidades para la Vida para Jóvenes",
            descripcion: "Comparte tus habilidades y experiencias en talleres diseñados para empoderar a jóvenes de la comunidad.",
            tipo: "Educativo",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 1, to: Date())!.addingTimeInterval(3600*2),
            ubicacionNombre: "Casa de la Juventud",
            latitud: 32.5470,
            longitud: -117.0280,
            organizador: "Impulso Juvenil AC",
            cupoMaximo: 30,
            horasLiberadas: 25
    ),
        Evento(
            nombre: "Cuidado de Jardín Comunitario",
            descripcion: "Ayuda a mantener y mejorar un jardín comunitario, cultivando alimentos y embelleciendo el espacio.",
            tipo: "Ambiental",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 28, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 28, to: Date())!.addingTimeInterval(3600*3),
            ubicacionNombre: "Jardín Comunitario El Paraíso",
            latitud: 32.4955,
            longitud: -116.9585,
            organizador: "Siembra Comunidad",
            cupoMaximo: 20,
            horasLiberadas: 12
    ),
        Evento(
            nombre: "Apoyo en Actividades para Personas con Discapacidad",
            descripcion: "Sé voluntario apoyando en diversas actividades recreativas y educativas para personas con discapacidad.",
            tipo: "Inclusivo",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 2, to: Date())!.addingTimeInterval(3600*4),
            ubicacionNombre: "Centro de Atención Integral",
            latitud: 32.5715,
            longitud: -117.0190,
            organizador: "Integración para Todos AC",
            cupoMaximo: 15,
            horasLiberadas: 30
    ),
        Evento(
            nombre: "Organización de Evento Cultural para la Comunidad",
            descripcion: "Participa en la planificación y ejecución de un evento cultural que promueva las artes y la cultura local.",
            tipo: "Cultural",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 30, to: Date())!.addingTimeInterval(3600*6),
            ubicacionNombre: "Explanada del Palacio Municipal",
            latitud: 32.5100,
            longitud: -117.0395,
            organizador: "Instituto Municipal de Arte y Cultura",
            cupoMaximo: 25,
            horasLiberadas: 20
    )
    Evento(
            nombre: "Apoyo en la Elaboración de Despensas",
            descripcion: "Ayuda a armar despensas con alimentos no perecederos para familias de bajos recursos en la comunidad.",
            tipo: "Social",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 12, to: Date())!.addingTimeInterval(3600*4),
            ubicacionNombre: "Bodega Comunitaria La Mesa",
            latitud: 32.5430,
            longitud: -116.9550,
            organizador: "Banco de Alimentos de Tijuana",
            cupoMaximo: 30,
            horasLiberadas: 15
    ),
        Evento(
            nombre: "Taller de Reparación de Bicicletas",
            descripcion: "Comparte tus conocimientos en mecánica de bicicletas enseñando a otros a reparar y mantener sus bicis.",
            tipo: "Comunitario",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 1, to: Date())!.addingTimeInterval(3600*3),
            ubicacionNombre: "Espacio Vecinal Rodante",
            latitud: 32.5215,
            longitud: -117.0410,
            organizador: "BiciRed Tijuana",
            cupoMaximo: 15,
            horasLiberadas: 18
    ),
        Evento(
            nombre: "Visitas a Pacientes en Hospital Infantil",
            descripcion: "Brinda alegría y compañía a niños hospitalizados a través de juegos y actividades recreativas.",
            tipo: "Social",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 19, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 19, to: Date())!.addingTimeInterval(3600*2),
            ubicacionNombre: "Hospital Infantil de las Californias",
            latitud: 32.5380,
            longitud: -117.0020,
            organizador: "Fundación Sonrisas",
            cupoMaximo: 10,
            horasLiberadas: 10
    ),
        Evento(
            nombre: "Apoyo en Campaña de Vacunación",
            descripcion: "Colabora en la logística y organización de una campaña de vacunación en diferentes puntos de la ciudad.",
            tipo: "Salud",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 26, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 26, to: Date())!.addingTimeInterval(3600*5),
            ubicacionNombre: "Diversas Delegaciones de Tijuana",
            latitud: 32.5150,
            longitud: -117.0350,
            organizador: "Secretaría de Salud",
            cupoMaximo: 20,
            horasLiberadas: 20
    ),
        Evento(
            nombre: "Taller de Creación de Instrumentos Musicales con Materiales Reciclados",
            descripcion: "Imparte un taller donde los participantes aprenderán a crear instrumentos musicales utilizando objetos reciclados.",
            tipo: "Cultural",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 2, to: Date())!.addingTimeInterval(3600*3),
            ubicacionNombre: "Casa de la Cultura El Pípila",
            latitud: 32.6020,
            longitud: -116.9100,
            organizador: "Arte para Todos",
            cupoMaximo: 25,
            horasLiberadas: 15
    ),
        Evento(
            nombre: "Apoyo en la Protección de Tortugas Marinas",
            descripcion: "Participa en actividades de vigilancia y protección de nidos de tortugas marinas en las playas cercanas.",
            tipo: "Ambiental",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 15, to: Date())!.addingTimeInterval(3600*4),
            ubicacionNombre: "Playas de Rosarito",
            latitud: 32.3000,
            longitud: -117.0400,
            organizador: "Conservación de Tortugas Marinas",
            cupoMaximo: 15,
            horasLiberadas: 18
    ),
        Evento(
            nombre: "Asistencia en Evento Deportivo para Niños",
            descripcion: "Ayuda en la organización y desarrollo de juegos y actividades deportivas para niños de la comunidad.",
            tipo: "Deportivo",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 21, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 21, to: Date())!.addingTimeInterval(3600*3),
            ubicacionNombre: "Unidad Deportiva Tijuana Este",
            latitud: 32.5850,
            longitud: -116.9050,
            organizador: "Deporte Comunitario",
            cupoMaximo: 20,
            horasLiberadas: 12
    ),
        Evento(
            nombre: "Tutorías de Matemáticas para Estudiantes de Primaria",
            descripcion: "Ofrece apoyo académico en matemáticas a niños de primaria que lo necesiten.",
            tipo: "Educativo",
            fechaInicio: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .month, value: 1, to: Date())!.addingTimeInterval(3600*2),
            ubicacionNombre: "Centro de Aprendizaje Niños Felices",
            latitud: 32.4900,
            longitud: -116.9800,
            organizador: "Apoyo Escolar AC",
            cupoMaximo: 10,
            horasLiberadas: 20
    ),
        Evento(
            nombre: "Acompañamiento a Personas con Discapacidad Visual",
            descripcion: "Brinda apoyo y acompañamiento a personas con discapacidad visual en actividades cotidianas y eventos.",
            tipo: "Inclusivo",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 28, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 28, to: Date())!.addingTimeInterval(3600*3),
            ubicacionNombre: "Instituto para Invidentes Tijuana",
            latitud: 32.5520,
            longitud: -117.0600,
            organizador: "Ver con el Corazón",
            cupoMaximo: 8,
            horasLiberadas: 15
    ),
        Evento(
            nombre: "Apoyo en la Organización de Mercadito Comunitario",
            descripcion: "Colabora en la organización y logística de un mercado comunitario que promueve productos locales y el comercio justo.",
            tipo: "Comunitario",
            fechaInicio: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            fechaFin: Calendar.current.date(byAdding: .day, value: 10, to: Date())!.addingTimeInterval(3600*5),
            ubicacionNombre: "Parque Hidalgo, Tijuana",
            latitud: 32.5180,
            longitud: -117.0250,
            organizador: "Mercado Solidario",
            cupoMaximo: 15,
            horasLiberadas: 18
    )
]
