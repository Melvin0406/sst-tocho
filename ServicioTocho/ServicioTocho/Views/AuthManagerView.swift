//
//  AuthManagerView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//

import SwiftUI

struct AuthManagerView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some View {
        // En lugar de usar Group, devolvemos directamente la vista condicional.
        // El @ViewBuilder implícito del 'body' debería manejar esto.
        if authViewModel.userIsLoggedIn {
            EventosListView(authViewModel: authViewModel)
        } else {
            LoginView(authViewModel: authViewModel)
        }
        // Si necesitas evitar la animación por defecto al cambiar entre estas vistas,
        // puedes añadir el modificador .animation(nil, value: authViewModel.userIsLoggedIn) aquí.
        // Ejemplo:
        // .animation(.default, value: authViewModel.userIsLoggedIn) // o .animation(nil, ...)
    }
}

struct AuthManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AuthManagerView()
    }
}
