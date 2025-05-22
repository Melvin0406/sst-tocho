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
    @State private var mostrarFiltro = false
    @ObservedObject var authViewModel: AuthenticationViewModel

    var tiposDeEventos: [String] {
        let tipos = Set(eventos.map { $0.tipo })
        return ["Todos"] + Array(tipos).sorted()
    }

    var eventosFiltrados: [Evento] {
        // Obtener los IDs de eventos para los cuales ya se registraron horas
        let idsEventosConHorasYaRegistradas = Set(authViewModel.misRegistrosDeHoras.compactMap { $0.idEvento })

        return eventos.filter { evento in
            // Condición para excluir eventos si ya se registraron horas para ellos
            guard let currentEventoID = evento.id, !currentEventoID.isEmpty else {
                return false // Excluir eventos sin ID válido
            }
            if idsEventosConHorasYaRegistradas.contains(currentEventoID) {
                return false // Si ya se registraron horas para este evento, no mostrarlo en esta lista
            }

            // Filtros Existentes
            let filtroTipo = (filtro.tipoSeleccionado == "Todos" || evento.tipo == filtro.tipoSeleccionado)
            
            let filtroFechaDesde = Calendar.current.compare(evento.fechaInicio, to: filtro.fechaDesde, toGranularity: .day) != .orderedAscending
            let filtroFechaHasta = Calendar.current.compare(evento.fechaInicio, to: filtro.fechaHasta, toGranularity: .day) != .orderedDescending
            
            let filtroUbicacion = (filtro.ubicacion.isEmpty || evento.ubicacionNombre.localizedCaseInsensitiveContains(filtro.ubicacion))
            
            var isActuallyRegisteredForThisEvent = false
            if let validEventID = evento.id, !validEventID.isEmpty {
                isActuallyRegisteredForThisEvent = authViewModel.isUserRegisteredForEvent(eventID: validEventID)
            }
            let filtroUnidos = (!filtro.soloUnidos || isActuallyRegisteredForThisEvent)
            
            return filtroTipo && filtroFechaDesde && filtroFechaHasta && filtroUbicacion && filtroUnidos
        }
    }

    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)

                Group {
                    if eventosFiltrados.isEmpty {
                        VStack {
                            Spacer()
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.7))
                            Text(authViewModel.misRegistrosDeHoras.isEmpty && filtro.soloUnidos ? "No te has unido a eventos que cumplan este filtro" : "No hay eventos disponibles")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            Text("Intenta ajustar los filtros o vuelve más tarde.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 1)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(eventosFiltrados) { evento in
                                ZStack {
                                    NavigationLink(destination: EventoDetalleView(evento: evento, authViewModel: authViewModel)) {
                                        EmptyView()
                                    }
                                    .opacity(0)

                                    EventoRowView(evento: evento, authViewModel: authViewModel)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.appBackground)
                    }
                }
            }
            .navigationTitle("Próximos Eventos")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                        Image(systemName: "person.circle.fill")
                            .imageScale(.large)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { mostrarFiltro = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $mostrarFiltro) {
                FiltroEventosView(filtro: filtro, tiposDeEventosDisponibles: tiposDeEventos)
            }
            .onAppear {
                if authViewModel.userProfile == nil, let uid = authViewModel.currentUser()?.uid {
                    authViewModel.fetchUserProfile(uid: uid)
                }
                authViewModel.fetchMisRegistrosDeHoras()
            }
        }
        .accentColor(Color.accentColorTeal)
    }
}
