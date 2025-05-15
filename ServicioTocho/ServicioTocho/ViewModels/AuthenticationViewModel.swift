//
//  AuthenticationViewModel.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//


import Foundation
import FirebaseAuth
// No necesitamos importar FirebaseFirestore ahora

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var userIsLoggedIn = false
    @Published var errorMessage: String?

    private var authStateHandler: AuthStateDidChangeListenerHandle?
    // private var db = Firestore.firestore() // Ya no necesitamos Firestore aquí

    // Clave para UserDefaults donde guardaremos los usernames
    private let userPreferencesKeyPrefix = "voluntariadoAppUser_"

    init() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.userIsLoggedIn = (user != nil)
                if user == nil {
                    print("Usuario no logueado.")
                    // Podríamos limpiar el email/password aquí si es necesario
                    // self?.email = ""
                    // self?.password = ""
                } else {
                    print("Usuario logueado: \(user?.uid ?? "sin UID")")
                    // Al loguearse, podríamos cargar el username si es necesario en este punto,
                    // o dejar que ProfileView lo haga cuando se muestre.
                }
                self?.errorMessage = nil // Limpiar mensajes de error al cambiar estado de login
            }
        }
    }

    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Nueva función de registro con username guardado localmente
    func signUpAndStoreUsernameLocally(username: String, email: String, password: String) {
        self.errorMessage = nil
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, completa todos los campos."
            return
        }
        // Validaciones adicionales (ej. longitud de contraseña) podrían ir aquí

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Error al crear usuario en Auth: \(error.localizedDescription)")
                    return
                }

                guard let user = authResult?.user else {
                    self.errorMessage = "No se pudo obtener el usuario después de la creación."
                    print("Error: authResult.user es nil")
                    return
                }

                // Guardar el username en UserDefaults asociado al UID del usuario
                let defaults = UserDefaults.standard
                defaults.set(username, forKey: "\(self.userPreferencesKeyPrefix)username_\(user.uid)")
                print("Usuario \(username) con UID \(user.uid) registrado y username guardado localmente.")

                // userIsLoggedIn se actualizará automáticamente por el authStateHandler
                // y AuthManagerView cambiará la vista.
            }
        }
    }

    // Función para obtener el username localmente
    func getLocalUsername(for uid: String?) -> String? {
        guard let uid = uid else { return nil }
        let defaults = UserDefaults.standard
        return defaults.string(forKey: "\(userPreferencesKeyPrefix)username_\(uid)")
    }


    func login() {
        self.errorMessage = nil
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
                // self.userIsLoggedIn se actualizará por el listener
                print("Usuario inició sesión exitosamente: \(authResult?.user.uid ?? "")")
            }
        }
    }

    func signOut() {
        do {
            // Antes de cerrar sesión, podrías limpiar el username si lo deseas,
            // o simplemente dejarlo en UserDefaults. Si otro usuario inicia sesión en el mismo dispositivo,
            // se buscará su propio username basado en su UID.
            try Auth.auth().signOut()
            // self.userIsLoggedIn se actualizará por el listener
            self.email = "" // Limpiar campos del ViewModel
            self.password = ""
            self.errorMessage = nil
            print("Usuario cerró sesión.")
        } catch let signOutError as NSError {
            self.errorMessage = "Error al cerrar sesión: \(signOutError.localizedDescription)"
            print("Error signing out: %@", signOutError)
        }
    }

    // Funciones para ProfileView
    func emailForProfile() -> String? {
        return Auth.auth().currentUser?.email
    }

    func usernameForProfile() -> String? { // Nueva función
        return getLocalUsername(for: Auth.auth().currentUser?.uid)
    }

    func currentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
}
