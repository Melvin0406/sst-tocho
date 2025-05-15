//
//  EventosListView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//
import SwiftUI

struct EventosListView: View {
    @State var eventos: [Evento] = mockEventos
    @StateObject var filtro = EventoFiltro()
    @State private var eventosUnidos: Set<UUID> = []
    @State private var mostrarFiltro = false
    @ObservedObject var authViewModel: AuthenticationViewModel

    var tiposDeEventos: [String] {
        let tipos = Set(eventos.map { $0.tipo })
        return ["Todos"] + Array(tipos)
    }

    var eventosFiltrados: [Evento] {
        eventos.filter { evento in
            (filtro.tipoSeleccionado == "Todos" || evento.tipo == filtro.tipoSeleccionado) &&
            evento.fechaInicio >= filtro.fechaDesde &&
            evento.fechaInicio <= filtro.fechaHasta &&
            (filtro.ubicacion.isEmpty || evento.ubicacionNombre.localizedCaseInsensitiveContains(filtro.ubicacion)) &&
            (!filtro.soloUnidos || eventosUnidos.contains(evento.id))
        }
    }

    var body: some View {
        NavigationView {
            List(eventosFiltrados) { evento in
                NavigationLink(destination: EventoDetalleView(evento: evento, eventosUnidos: $eventosUnidos)) {
                    EventoRowView(evento: evento)
                }
            }
            .navigationTitle("Próximos Eventos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        mostrarFiltro = true
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $mostrarFiltro) {
                FiltroEventosView(filtro: filtro)
            }
        }
    }
}

struct EventosListView_Previews: PreviewProvider {
    static var previews: some View {
        // Asegúrate de pasar el authViewModel correctamente
        EventosListView(authViewModel: AuthenticationViewModel()) // Pasando el authViewModel
    }
}
