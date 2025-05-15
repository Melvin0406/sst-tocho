//
//  ProfileView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    // Para cerrar esta vista modalmente si se presenta como .sheet, o para pop en NavigationStack
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView { // Opcional si ya estás dentro de una NavigationView, pero bueno para el título
            VStack {
                Text("Perfil del Usuario") // Placeholder para más contenido del perfil
                    .font(.largeTitle)
                    .padding()

                if let email = authViewModel.emailForProfile() { // Usaremos una función para obtener el email
                    Text("Correo: \(email)")
                        .padding()
                } else if let user = authViewModel.currentUser() {
                    Text("UID: \(user.uid)")
                        .padding()
                }


                Spacer() // Empuja el botón hacia abajo

                Button(action: {
                    authViewModel.signOut()
                    // No es necesario llamar a dismiss() aquí si AuthManagerView maneja el cambio de vista
                    // cuando userIsLoggedIn cambia a false.
                    // Si ProfileView se presentara como una modal (.sheet), aquí podrías llamar a dismiss().
                }) {
                    Text("Cerrar Sesión")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Mi Perfil")
            .navigationBarTitleDisplayMode(.inline) // O .large
            // Opcional: botón para cerrar si se presenta como sheet y no en NavigationView
            // .toolbar {
            //     ToolbarItem(placement: .navigationBarLeading) {
            //         Button("Cerrar") {
            //             dismiss()
            //         }
            //     }
            // }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Creamos una instancia de mock para la preview
        let mockAuthViewModel = AuthenticationViewModel()
        // Opcionalmente, simula un usuario logueado para la preview
        // Esto es más complejo de simular directamente sin un login real en preview,
        // pero podemos pasar un ViewModel básico.
        ProfileView(authViewModel: mockAuthViewModel)
    }
}
