//
//  EventosListView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI

struct EventosListView: View {
    // Usaremos nuestros datos de ejemplo por ahora
    // Más adelante, esto vendrá de un ViewModel o una fuente de datos persistente
    @State var eventos: [Evento] = mockEventos

    var body: some View {
        NavigationView { // Necesario para la barra de título y futura navegación
            List(eventos) { evento in
                // Envolvemos la fila en NavigationLink para futura navegación al detalle
                NavigationLink(destination: EventoDetalleView(evento: evento)) {
                    EventoRowView(evento: evento)
                }
            }
            .navigationTitle("Próximos Eventos")
        }
    }
}

// Vista de detalle de placeholder (la crearemos en el siguiente paso)
struct EventoDetalleView: View {
    let evento: Evento
    var body: some View {
        Text("Detalle del evento: \(evento.nombre)")
            .navigationTitle(evento.nombre)
    }
}

struct EventosListView_Previews: PreviewProvider {
    static var previews: some View {
        EventosListView()
    }
}
