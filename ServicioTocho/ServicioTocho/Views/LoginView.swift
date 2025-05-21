//
//  LoginView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel

    // Inicializador para configurar la apariencia de la barra de navegación
    init(authViewModel: AuthenticationViewModel) {
        self.authViewModel = authViewModel

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appBackground) // Fondo de la barra
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label] // Color de título adaptable
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.accentColorTeal) // Color de botones/iconos de la barra
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.edgesIgnoringSafeArea(.all)

                ScrollView { // Para asegurar que el contenido sea scrolleable en pantallas pequeñas
                    VStack(spacing: 25) { // Aumentamos un poco el espaciado general
                        
                        // Icono/Logo de la App (Placeholder)
                        Image(systemName: "hand.raised.heart.fill") // Un icono relacionado con voluntariado
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.accentColorTeal.opacity(0.8))
                            .padding(.top, 40)
                            .padding(.bottom, 10)

                        Text("Bienvenido a VoluntariadoApp")
                            .font(.title2) // Un poco más pequeño para balancear con el icono
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                            .padding(.bottom, 30)

                        // Campo de Correo Electrónico
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Correo Electrónico")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color.accentColorTeal)
                                TextField("usuario@ejemplo.com", text: $authViewModel.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding(12)
                            .background(Color(UIColor.secondarySystemGroupedBackground)) // Fondo más sutil
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1) // Borde sutil
                            )
                        }
                        
                        // Campo de Contraseña
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Contraseña")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color.accentColorTeal)
                                SecureField("Ingresa tu contraseña", text: $authViewModel.password)
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
                                .font(.footnote) // Un poco más pequeño
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Button(action: {
                            authViewModel.login()
                        }) {
                            Text("Iniciar Sesión")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColorTeal) // Usar color de acento
                                .cornerRadius(10)
                                .shadow(color: Color.accentColorTeal.opacity(0.4), radius: 5, x: 0, y: 3)
                        }
                        .padding(.top, 10) // Espacio antes del botón

                        NavigationLink(destination: SignUpView()) {
                            Text("¿No tienes cuenta? Regístrate")
                                .fontWeight(.medium)
                                // El color debería ser tomado del .accentColor de la NavigationView
                        }
                        .padding(.top, 5)
                        
                        Spacer() // Para empujar el contenido si la pantalla es grande

                    }
                    .padding(.horizontal, 30) // Padding horizontal para el contenido del VStack
                }
            }
            .navigationTitle("Acceso")
            // .navigationBarHidden(true) // Descomenta si NO quieres la barra de navegación aquí
        }
        .accentColor(Color.accentColorTeal) // Aplica el color de acento a toda la NavigationView
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authViewModel: AuthenticationViewModel())
    }
}
