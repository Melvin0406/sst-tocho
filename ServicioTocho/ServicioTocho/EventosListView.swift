//
//  EventosListView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI

struct EventosListView: View {
    @State var eventos: [Evento] = mockEventos
    @ObservedObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationView {
            List(eventos) { evento in
                NavigationLink(destination: EventoDetalleView(evento: evento)) {
                    EventoRowView(evento: evento)
                }
            }
            .navigationTitle("Próximos Eventos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { // Botón a la derecha
                    NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                        Image(systemName: "person.circle") // Icono de perfil
                            .imageScale(.large) // Hace el icono un poco más grande
                    }
                }
            }
        }
    }
}

struct EventosListView_Previews: PreviewProvider {
    static var previews: some View {
        EventosListView(authViewModel: AuthenticationViewModel())
    }
}
