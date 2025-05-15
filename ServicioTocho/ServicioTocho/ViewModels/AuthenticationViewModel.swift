//
//  AuthenticationViewModel.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import Foundation
import FirebaseAuth // Importa FirebaseAuth

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var userIsLoggedIn = false
    @Published var errorMessage: String?

    private var authStateHandler: AuthStateDidChangeListenerHandle? // Para escuchar cambios de estado

    init() {
        // Escuchar cambios en el estado de autenticación de Firebase
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.userIsLoggedIn = (user != nil) // user es nil si no hay nadie logueado
                if user == nil {
                    print("Usuario no logueado.")
                } else {
                    print("Usuario logueado: \(user?.uid ?? "sin UID")")
                    // Aquí podrías cargar datos del usuario desde Firestore si es necesario
                }
            }
        }
    }

    deinit {
        // Dejar de escuchar cuando el ViewModel se destruya
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa correo y contraseña."
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("Error al crear usuario: \(error.localizedDescription)")
                    return
                }
                // El usuario se creó y se logueó automáticamente
                // El addStateDidChangeListener se encargará de actualizar userIsLoggedIn
                self?.errorMessage = nil
                print("Usuario creado exitosamente: \(authResult?.user.uid ?? "")")
            }
        }
    }

    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa correo y contraseña."
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    print("Error al iniciar sesión: \(error.localizedDescription)")
                    return
                }
                // El usuario inició sesión exitosamente
                // El addStateDidChangeListener se encargará de actualizar userIsLoggedIn
                self?.errorMessage = nil
                print("Usuario inició sesión exitosamente: \(authResult?.user.uid ?? "")")
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // El addStateDidChangeListener se encargará de actualizar userIsLoggedIn
            // Limpia los campos si quieres
            // self.email = ""
            // self.password = ""
            self.errorMessage = nil
            print("Usuario cerró sesión.")
        } catch let signOutError as NSError {
            self.errorMessage = "Error al cerrar sesión: \(signOutError.localizedDescription)"
            print("Error signing out: %@", signOutError)
        }
    }
    
    func emailForProfile() -> String? {
        return Auth.auth().currentUser?.email
    }

    func currentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
