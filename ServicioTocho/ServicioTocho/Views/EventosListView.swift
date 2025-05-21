//
//  EventosListView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//
import SwiftUI

struct EventosListView: View {
    @State var eventos: [Evento] = mockEventos // Tus datos de ejemplo o los que cargues
    @StateObject var filtro = EventoFiltro()
    // Se elimina @State private var eventosUnidos: Set<UUID> = []
    @State private var mostrarFiltro = false
    @ObservedObject var authViewModel: AuthenticationViewModel

    var tiposDeEventos: [String] {
        // Esta lógica está bien para obtener los tipos únicos de tus eventos actuales
        let tipos = Set(eventos.map { $0.tipo })
        return ["Todos"] + Array(tipos).sorted()
    }

    var eventosFiltrados: [Evento] {
        eventos.filter { evento in
            let filtroTipo = (filtro.tipoSeleccionado == "Todos" || evento.tipo == filtro.tipoSeleccionado)
            
            // Ajustar comparación de fechas para ignorar la hora y solo comparar el día
            let filtroFechaDesde = Calendar.current.compare(evento.fechaInicio, to: filtro.fechaDesde, toGranularity: .day) != .orderedAscending
            let filtroFechaHasta = Calendar.current.compare(evento.fechaInicio, to: filtro.fechaHasta, toGranularity: .day) != .orderedDescending
            
            let filtroUbicacion = (filtro.ubicacion.isEmpty || evento.ubicacionNombre.localizedCaseInsensitiveContains(filtro.ubicacion))
            
            // Usar authViewModel para verificar si el usuario está unido al evento
            var isActuallyRegistered = false // Por defecto, no registrado si el ID es inválido o nil
            if let validEventID = evento.id, !validEventID.isEmpty {
                isActuallyRegistered = authViewModel.isUserRegisteredForEvent(eventID: validEventID)
            }
            let filtroUnidos = (!filtro.soloUnidos || isActuallyRegistered)
            
            return filtroTipo && filtroFechaDesde && filtroFechaHasta && filtroUbicacion && filtroUnidos
        }
    }

    var body: some View {
        NavigationView {
            List(eventosFiltrados) { evento in
                NavigationLink(destination: EventoDetalleView(evento: evento, authViewModel: authViewModel)) {
                    EventoRowView(evento: evento) // Asumo que EventoRowView está definida
                }
            }
            .navigationTitle("Próximos Eventos")
            .toolbar {
                // Botón de Perfil a la izquierda
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }

                // Botón de Filtro a la derecha
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
                // Pasamos los tipos de eventos disponibles al filtro si es necesario
                FiltroEventosView(filtro: filtro, tiposDeEventosDisponibles: tiposDeEventos)
            }
            .onAppear {
                if authViewModel.userProfile == nil, let uid = authViewModel.currentUser()?.uid {
                    authViewModel.fetchUserProfile(uid: uid)
                }
            }
        }
    }
}
