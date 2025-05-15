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
        }
    }
}

struct EventosListView_Previews: PreviewProvider {
    static var previews: some View {
        EventosListView(authViewModel: AuthenticationViewModel())
    }
}
