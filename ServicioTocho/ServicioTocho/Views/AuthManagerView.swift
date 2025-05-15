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
        // Group permite cambiar entre vistas sin animaciones de transición no deseadas
        // a menos que se especifiquen explícitamente.
        Group {
            if authViewModel.userIsLoggedIn {
                // Si el usuario está logueado, muestra la lista de eventos
                // Aquí podrías pasar el viewModel o el usuario si EventosListView lo necesita
                EventosListView()
                // También podrías añadir un botón de "Cerrar Sesión" en EventosListView
                // o en una vista de perfil, que llame a authViewModel.signOut()
            } else {
                // Si no está logueado, muestra la vista de login
                LoginView(authViewModel: authViewModel) // Pasamos la instancia existente
            }
        }
        // Puedes añadir .animation(nil, value: authViewModel.userIsLoggedIn) si quieres evitar
        // una animación por defecto al cambiar entre estas vistas.
    }
}

// Necesitamos modificar LoginView para aceptar el ViewModel
// Vuelve a LoginView.swift y cambia la línea:
// @StateObject private var authViewModel = AuthenticationViewModel()
// por:
// @ObservedObject var authViewModel: AuthenticationViewModel
//
// Y en LoginView_Previews, tendrás que instanciarlo:
// LoginView(authViewModel: AuthenticationViewModel())

struct AuthManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AuthManagerView()
    }
}