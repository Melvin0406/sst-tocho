//
//  ProfileView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        // La NavigationView aquí es para el título de ProfileView y su propio estilo de barra
        NavigationView {
            VStack(alignment: .leading, spacing: 15) { // Alineación a la izquierda
                Text("Mi Perfil")
                    .font(.largeTitle)
                    .padding(.bottom)

                if let nombreComp = authViewModel.nombreCompletoForProfile() { // Usamos la nueva función
                    HStack {
                        Text("Nombre Completo:").bold()
                        Text(nombreComp)
                    }
                } else {
                    HStack {
                        Text("Nombre Completo:").bold()
                        Text("No disponible")
                    }
                }

                if let email = authViewModel.emailForProfile() {
                    HStack {
                        Text("Correo:").bold()
                        Text(email)
                    }
                }
                
                if let horas = authViewModel.userProfile?.horasAcumuladas {
                    HStack {
                        Text("Horas Acumuladas:").bold()
                        Text(String(format: "%.1f", horas)) // Formatear a 1 decimal
                    }
                }

                Spacer()

                Button(action: {
                    authViewModel.signOut()
                    // AuthManagerView se encargará de la navegación
                }) {
                    Text("Cerrar Sesión")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) // Para que el VStack ocupe el ancho
            .navigationTitle("Detalles del Perfil") // Título de la barra de navegación
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAuthVM = AuthenticationViewModel()
        // Para la preview, podrías simular un UID y guardar un username de prueba
        // if let testUID = "previewUID123" {
        //     UserDefaults.standard.set("UsuarioPreview", forKey: "\(mockAuthVM.userPreferencesKeyPrefix)username_\(testUID)")
        //     // Luego necesitarías una forma de que mockAuthVM.currentUser() devuelva un User con ese UID.
        //     // Es más fácil probar esto en el flujo real de la app.
        // }
        ProfileView(authViewModel: mockAuthVM)
    }
}
