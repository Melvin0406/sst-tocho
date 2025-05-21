//
//  ProfileView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    // @Environment(\.dismiss) var dismiss // No es necesario si solo se usa .pop de NavigationView

    // No necesitamos un init() para la barra de navegación aquí,
    // ya que la barra es proporcionada por EventosListView.
    // El .accentColor en EventosListView debería aplicar el tint a los botones de esta barra.

    var body: some View {
        ZStack { // ZStack para el color de fondo general
            Color.appBackground.edgesIgnoringSafeArea(.all)

            ScrollView { // Usamos ScrollView por si el contenido crece
                VStack(spacing: 20) { // Espaciador principal para el contenido
                    
                    // Sección del Cabezal del Perfil (Avatar y Nombre)
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill") // Placeholder para avatar
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(Color.accentColorTeal.opacity(0.7))
                            .padding(.top, 20)

                        if let nombreComp = authViewModel.nombreCompletoForProfile() {
                            Text(nombreComp)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.primary)
                        } else {
                            Text("Nombre no disponible")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        }
                        
                        if let email = authViewModel.emailForProfile() {
                            Text(email)
                                .font(.callout)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 20)

                    // Tarjeta de Detalles del Usuario
                    VStack(alignment: .leading, spacing: 18) {
                        DetailRow(iconName: "number.circle.fill", label: "Horas Acumuladas", value: String(format: "%.1f", authViewModel.userProfile?.horasAcumuladas ?? 0.0))
                        
                        // Podríamos añadir más detalles aquí en el futuro
                        // DetailRow(iconName: "calendar.circle.fill", label: "Eventos Registrados", value: "\(authViewModel.userProfile?.registeredEventIDs?.count ?? 0)")
                    }
                    .padding(20)
                    .background(Color(UIColor.secondarySystemGroupedBackground)) // Fondo de la tarjeta
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.horizontal)


                    Spacer() // Empuja el botón de cerrar sesión hacia abajo

                    Button(action: {
                        authViewModel.signOut()
                        // AuthManagerView se encargará de la navegación al cambiar userIsLoggedIn
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.square.fill")
                            Text("Cerrar Sesión")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Mi Perfil") // Este título se mostrará en la barra de EventosListView
        .navigationBarTitleDisplayMode(.inline)
        // El accentColor aplicado en EventosListView debería teñir el botón "Atrás"
    }
}

// Subvista para las filas de detalle dentro de la tarjeta de perfil
struct DetailRow: View {
    var iconName: String
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundColor(Color.accentColorTeal) // Usar color de acento para iconos
                .frame(width: 30, alignment: .center)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            Spacer() // Para alinear el contenido a la izquierda
        }
    }
}
