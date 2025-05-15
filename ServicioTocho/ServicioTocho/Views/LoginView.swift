//
//  LoginView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel

    var body: some View {
        NavigationView { // Opcional, pero útil si quieres un título o botones en la barra
            VStack(spacing: 20) {
                Text("Bienvenido a VoluntariadoApp")
                    .font(.largeTitle)
                    .padding(.bottom, 40)

                TextField("Correo Electrónico", text: $authViewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                SecureField("Contraseña", text: $authViewModel.password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    authViewModel.login()
                }) {
                    Text("Iniciar Sesión")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                // Enlace para ir a la pantalla de registro
                NavigationLink(destination: SignUpView()) {
                    // SignUpView crea su propio authViewModel
                    Text("¿No tienes cuenta? Regístrate")
                        .padding(.top)
                }
                    // El botón de "Crear Cuenta Nueva" que estaba aquí antes se elimina si lo tenías.
                Spacer()
            }
            .padding()
            .navigationTitle("Acceso")
        }
        // La siguiente línea es importante: si el usuario se loguea/registra
        // y userIsLoggedIn cambia en el ViewModel, esta vista no desaparecerá
        // automáticamente. La lógica de cambio de vista estará en AuthManagerView.
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authViewModel: AuthenticationViewModel())
    }
}
