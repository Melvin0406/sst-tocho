//
//  SignUpView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct SignUpView: View {
    // Usaremos una instancia propia del ViewModel para esta pantalla,
    // ya que el flujo de registro es autocontenido aquí hasta que se completa.
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    // @State private var confirmPassword = "" // Opcional

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Crear Nueva Cuenta")
                    .font(.largeTitle)
                    .padding(.bottom, 30)

                TextField("Nombre de Usuario (local)", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )


                TextField("Correo Electrónico", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                SecureField("Contraseña", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .lineLimit(nil)
                        .padding(.horizontal)
                }

                Button(action: {
                    authViewModel.signUpAndCreateUserProfile(
                        username: username,
                        email: email,
                        password: password
                    )
                }) {
                    Text("Registrarse")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Registro")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(authViewModel.$userIsLoggedIn) { isLoggedIn in
                if isLoggedIn {
                    // AuthManagerView se encargará del cambio de vista principal.
                    // Este dismiss es para cerrar la vista de SignUp en sí misma.
                    dismiss()
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
