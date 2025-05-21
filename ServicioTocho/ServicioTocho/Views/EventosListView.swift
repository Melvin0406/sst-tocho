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
    @State private var mostrarFiltro = false
    @ObservedObject var authViewModel: AuthenticationViewModel

    var tiposDeEventos: [String] {
        let tipos = Set(eventos.map { $0.tipo })
        return ["Todos"] + Array(tipos).sorted()
    }

    var eventosFiltrados: [Evento] {
        eventos.filter { evento in
            let filtroTipo = (filtro.tipoSeleccionado == "Todos" || evento.tipo == filtro.tipoSeleccionado)
            let filtroFechaDesde = Calendar.current.compare(evento.fechaInicio, to: filtro.fechaDesde, toGranularity: .day) != .orderedAscending
            let filtroFechaHasta = Calendar.current.compare(evento.fechaInicio, to: filtro.fechaHasta, toGranularity: .day) != .orderedDescending
            let filtroUbicacion = (filtro.ubicacion.isEmpty || evento.ubicacionNombre.localizedCaseInsensitiveContains(filtro.ubicacion))
            
            var isActuallyRegistered = false
            if let validEventID = evento.id, !validEventID.isEmpty {
                isActuallyRegistered = authViewModel.isUserRegisteredForEvent(eventID: validEventID)
            }
            let filtroUnidos = (!filtro.soloUnidos || isActuallyRegistered)
            
            return filtroTipo && filtroFechaDesde && filtroFechaHasta && filtroUbicacion && filtroUnidos
        }
    }
    
    init(authViewModel: AuthenticationViewModel) {
            self.authViewModel = authViewModel
            
            // Configuración de la apariencia de la barra de navegación (opcional pero recomendado para consistencia)
            // Esto se puede mover a un modificador de vista global o al .onAppear si prefieres
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.appBackground) // Color de fondo de la barra de navegación
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Color del título
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black] // Color del título grande

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance // Para iPads y orientaciones compactas

            // Color de los íconos de la barra de navegación (botones)
            UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal)
        }

    var body: some View {
           NavigationView {
               ZStack { // Usamos ZStack para poner el color de fondo detrás de todo
                   Color.appBackground.edgesIgnoringSafeArea(.all) // Aplicar color de fondo a toda la pantalla

                   Group {
                       if eventosFiltrados.isEmpty {
                           VStack {
                               Spacer()
                               Image(systemName: "calendar.badge.exclamationmark")
                                   .font(.system(size: 60))
                                   .foregroundColor(.gray.opacity(0.7))
                               Text("No hay eventos disponibles")
                                   .font(.title2)
                                   .foregroundColor(.gray)
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
                                   .listRowBackground(Color.clear) // Hacemos el fondo de la fila transparente
                               }
                           }
                           .listStyle(.plain)
                           .background(Color.appBackground) // Aseguramos que el fondo de la lista también sea el de la app
                       }
                   }
                   // El título y la toolbar se aplican a la NavigationView o a su contenido directo
               }
               .navigationTitle("Próximos Eventos")
               .toolbar {
                   ToolbarItem(placement: .navigationBarLeading) {
                       NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                           Image(systemName: "person.circle.fill")
                               .imageScale(.large)
                               // .foregroundColor(Color.accentColorTeal) // El tintColor global debería manejar esto
                       }
                   }
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button(action: { mostrarFiltro = true }) {
                           Image(systemName: "slider.horizontal.3")
                               .imageScale(.large)
                               // .foregroundColor(Color.accentColorTeal) // El tintColor global debería manejar esto
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
                   // Puedes volver a aplicar la apariencia aquí si es necesario,
                   // aunque el init es una opción para configuración global inicial.
               }
           }
           // Puedes aplicar .accentColor(Color.accentColorTeal) aquí a la NavigationView
           // para influir en el color de los elementos interactivos como los botones de la toolbar
           // si el tintColor global no lo toma.
           .accentColor(Color.accentColorTeal)
       }
   }

struct EventosListView_Previews: PreviewProvider {
    static var previews: some View {
        EventosListView(authViewModel: AuthenticationViewModel())
    }
}
