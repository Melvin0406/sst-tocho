//
//  SignUpView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var nombreCompleto = ""
    @State private var email = ""
    @State private var password = ""
    

    var body: some View {
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 25) {
                    Image(systemName: "person.fill.badge.plus") // Icono para registro
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color.accentColorTeal.opacity(0.8))
                        .padding(.top, 30)
                        .padding(.bottom, 10)

                    Text("Crear Nueva Cuenta")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .padding(.bottom, 30)

                    // Campo Nombre Completo
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Nombre Completo")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color.accentColorTeal)
                            TextField("Ingresa tu nombre completo", text: $nombreCompleto)
                                .autocapitalization(.words)
                                .disableAutocorrection(false)
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }

                    // Campo Correo Electrónico
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Correo Electrónico")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(Color.accentColorTeal)
                            TextField("usuario@ejemplo.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Campo Contraseña
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Contraseña")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color.accentColorTeal)
                            SecureField("Crea una contraseña segura", text: $password)
                        }
                        .padding(12)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button(action: {
                        authViewModel.signUpAndCreateUserProfile(
                            nombreCompleto: nombreCompleto,
                            email: email,
                            password: password
                        )
                    }) {
                        Text("Registrarse")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColorTeal)
                            .cornerRadius(10)
                            .shadow(color: Color.accentColorTeal.opacity(0.4), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(authViewModel.$userIsLoggedIn) { isLoggedIn in
            if isLoggedIn {
                dismiss()
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView()
        }
        .accentColor(Color.accentColorTeal) 
    }
}
