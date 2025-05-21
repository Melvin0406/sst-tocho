//
//  AuthenticationViewModel.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var userIsLoggedIn = false
    @Published var errorMessage: String?
    @Published var userProfile: UserProfile?
    @Published var misRegistrosDeHoras: [RegistroHora] = []

    private var authStateHandler: AuthStateDidChangeListenerHandle?
    private var db = Firestore.firestore()

    init() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return } // Asegura que self no es nil
            DispatchQueue.main.async {
                self.userIsLoggedIn = (user != nil)
                if let firebaseUser = user {
                    print("Usuario logueado con UID: \(firebaseUser.uid)")
                    self.fetchUserProfile(uid: firebaseUser.uid) // Cargar perfil al loguearse
                    self.fetchMisRegistrosDeHoras()
                } else {
                    print("Usuario no logueado.")
                    self.userProfile = nil // Limpiar perfil al cerrar sesión
                    self.misRegistrosDeHoras = []
                }
                // Limpiar mensajes de error al cambiar el estado de autenticación
                // Podrías decidir si quieres limpiar el errorMessage aquí o no,
                // ya que un error de login anterior podría ser relevante.
                // self.errorMessage = nil
            }
        }
    }

    // Nueva función para cargar el perfil del usuario desde Firestore
    func fetchUserProfile(uid: String) {
        db.collection("users").document(uid).getDocument { (documentSnapshot, error) in
            DispatchQueue.main.async {
                if let error = error {
                    // Manejar errores de red o del servicio de Firestore
                    print("Error al obtener perfil de usuario: \(error.localizedDescription)")
                    self.errorMessage = "No se pudo cargar el perfil: \(error.localizedDescription)"
                    self.userProfile = nil
                    return
                }

                if let document = documentSnapshot, document.exists {
                    do {
                        // Intenta decodificar el documento a tu struct UserProfile
                        self.userProfile = try document.data(as: UserProfile.self)
                        print("Perfil de usuario cargado: \(self.userProfile?.nombreCompleto ?? "N/A")")
                        print("Eventos registrados: \(self.userProfile?.registeredEventIDs ?? [])")
                        // Si necesitas actualizar alguna otra UI basada en el perfil cargado, puedes hacerlo aquí
                        // o emitir una notificación/actualización adicional si es complejo.
                    } catch {
                        print("Error al decodificar perfil de usuario: \(error.localizedDescription)")
                        self.errorMessage = "Error al leer datos del perfil."
                        self.userProfile = nil // Asegúrate de limpiar el perfil si hay error de decodificación
                    }
                } else {
                    print("Documento de perfil no existe en Firestore para UID: \(uid).")
                    // Esto es importante: el usuario está autenticado en Firebase Auth,
                    // pero no tiene un documento de perfil en Firestore.
                    // Esto podría ocurrir si el proceso de creación del perfil falló después del registro en Auth,
                    // o si es un usuario antiguo antes de que implementaras esta lógica de perfiles.
                    // Podrías decidir crear un perfil por defecto aquí.
                    self.errorMessage = "Perfil de usuario no encontrado en la base de datos."
                    self.userProfile = nil

                    // Opcional: Lógica para crear un perfil por defecto si no existe
                    // if Auth.auth().currentUser != nil { // Solo si el usuario está realmente logueado
                    //    print("Intentando crear perfil por defecto para usuario existente sin perfil en Firestore.")
                    //    // self.createDefaultProfileForCurrentUser() // Implementar esta función si es necesario
                    // }
                }
            }
        }
    }

    func signUpAndCreateUserProfile(nombreCompleto: String, email: String, password: String) {
        self.errorMessage = nil
        guard !nombreCompleto.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, completa todos los campos."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }

            guard let user = authResult?.user else {
                DispatchQueue.main.async {
                    self.errorMessage = "No se pudo obtener el usuario después de la creación."
                }
                return
            }

            // Crear el perfil de usuario para Firestore
            let newUserProfile = UserProfile(id: user.uid,
                                             nombreCompleto: nombreCompleto,
                                             email: email,
                                             horasAcumuladas: 0.0, // Valor inicial
                                             registeredEventIDs: [])

            do {
                // Guardar el perfil en Firestore en la colección "users"
                try self.db.collection("users").document(user.uid).setData(from: newUserProfile) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.errorMessage = "Error al guardar perfil: \(error.localizedDescription)"
                        } else {
                            print("Usuario creado en Auth y perfil guardado en Firestore.")
                            self.userProfile = newUserProfile // Actualiza el perfil localmente
                            // userIsLoggedIn será actualizado por el listener, lo que refrescará la UI
                        }
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error al preparar datos del perfil: \(error.localizedDescription)"
                    // Considera eliminar el usuario de Auth aquí también
                }
            }
        }
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

    func nombreCompletoForProfile() -> String? {
        return userProfile?.nombreCompleto
    }

    func currentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    func registerUserForEvent(eventID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Usuario no autenticado."
            return
        }
        
        db.collection("users").document(userID).updateData([
            "registeredEventIDs": FieldValue.arrayUnion([eventID])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error al registrarse al evento: \(error.localizedDescription)"
                } else {
                    print("Usuario registrado al evento \(eventID) exitosamente.")
                    // Actualizar el userProfile local para reflejar el cambio inmediatamente
                    if self.userProfile?.registeredEventIDs?.contains(eventID) == false {
                        self.userProfile?.registeredEventIDs?.append(eventID)
                    }
                    // self.objectWillChange.send() // Forzar actualización si es necesario, aunque @Published debería hacerlo
                }
            }
        }
    }

    func unregisterUserFromEvent(eventID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Usuario no autenticado."
            return
        }
        // Usamos FieldValue.arrayRemove para quitar el ID del evento del array
        db.collection("users").document(userID).updateData([
            "registeredEventIDs": FieldValue.arrayRemove([eventID])
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error al cancelar registro del evento: \(error.localizedDescription)"
                } else {
                    print("Registro al evento \(eventID) cancelado exitosamente.")
                    // Actualizar el userProfile local
                    self.userProfile?.registeredEventIDs?.removeAll(where: { $0 == eventID })
                    // self.objectWillChange.send()
                }
            }
        }
    }

    // Función helper para saber si un usuario está registrado a un evento específico
    func isUserRegisteredForEvent(eventID: String) -> Bool {
        return userProfile?.registeredEventIDs?.contains(eventID) ?? false
    }
    
    func fetchMisRegistrosDeHoras() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Usuario no autenticado, no se pueden cargar los registros de horas.")
            // Considera limpiar misRegistrosDeHoras si el usuario cierra sesión
            // self.misRegistrosDeHoras = []
            return
        }

        db.collection("registros_horas")
          .whereField("idUsuario", isEqualTo: userID)
          .order(by: "fecha", descending: true) // Opcional: ordenar por fecha de registro
          .getDocuments { querySnapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error al obtener registros de horas: \(error.localizedDescription)")
                    self.errorMessage = "No se pudo cargar el historial de horas: \(error.localizedDescription)"
                    self.misRegistrosDeHoras = [] // Limpiar en caso de error
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No se encontraron documentos de registros de horas.")
                    self.misRegistrosDeHoras = []
                    return
                }

                self.misRegistrosDeHoras = documents.compactMap { document -> RegistroHora? in
                    do {
                        return try document.data(as: RegistroHora.self)
                    } catch {
                        print("Error al decodificar RegistroHora: \(error.localizedDescription)")
                        return nil
                    }
                }
                print("Registros de horas cargados: \(self.misRegistrosDeHoras.count)")
            }
        }
    }
    
    func logHoursForEvent(eventoID: String, horas: Double, descripcion: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid, let userEmail = Auth.auth().currentUser?.email else {
            completion(false, "Usuario no autenticado.")
            return
        }

        guard var currentUserProfile = self.userProfile else {
            completion(false, "Perfil de usuario no cargado.")
            return
        }

        // 1. Crear el objeto RegistroHora
        let nuevoRegistro = RegistroHora(
            // id se genera automáticamente si es UUID, o se asigna por Firestore si es String y @DocumentID
            // Aquí asumimos que el id de RegistroHora será generado por Firestore si es @DocumentID String?
            // o se auto-genera si es UUID. Por ahora, el modelo tiene var id = UUID()
            idEvento: eventoID,
            idUsuario: userID,
            fecha: Date(), // Fecha actual del registro
            horasReportadas: horas,
            aprobado: true, // Auto-aprobado por ahora
            descripcionActividad: descripcion
        )

        // 2. Guardar el RegistroHora en Firestore (nueva colección "registros_horas")
        // Usamos un bloque de lote (batch) para asegurar que ambas operaciones (guardar registro y actualizar perfil)
        // se completen o fallen juntas, si es posible y deseado.
        // Por simplicidad, haremos operaciones separadas con manejo de errores individual.

        let registroRef = db.collection("registros_horas").document() // Firestore genera el ID para el nuevo registro

        do {
            try registroRef.setData(from: nuevoRegistro) { error in
                if let error = error {
                    print("Error al guardar RegistroHora en Firestore: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(false, "Error al guardar el registro de horas: \(error.localizedDescription)")
                    }
                    return
                }

                print("RegistroHora guardado exitosamente con ID: \(registroRef.documentID)")

                // --- INICIO DE LA ACTUALIZACIÓN IMPORTANTE ---
                // 1. Actualización optimista local de misRegistrosDeHoras
                // Esto hará que la UI reaccione más rápido.
                // Es importante que RegistroHora sea Equatable si quieres evitar duplicados exactos
                // o maneja la inserción/actualización con cuidado.
                // Como fetchMisRegistrosDeHoras() se llamará después, esto se sincronizará.
                DispatchQueue.main.async {
                                // Creamos una nueva copia del array, añadimos el nuevo registro,
                                // y luego reasignamos la propiedad @Published.
                                // Esto tiende a ser una señal más clara para SwiftUI de que el array ha cambiado.
                                var nuevosRegistros = self.misRegistrosDeHoras
                                nuevosRegistros.append(nuevoRegistro) // O insert(at: 0) si prefieres al inicio
                                self.misRegistrosDeHoras = nuevosRegistros
                                print("ViewModel: misRegistrosDeHoras actualizado localmente (optimista). Nuevo count: \(self.misRegistrosDeHoras.count)")
                            }


                // 2. Actualizar horasAcumuladas en UserProfile en Firestore
                // Obtenemos las horas acumuladas actuales del userProfile local o volvemos a pedirlas.
                // Es más seguro usar las horas del perfil que ya tenemos, si está actualizado.
                let horasActuales = self.userProfile?.horasAcumuladas ?? 0.0
                let nuevasHorasAcumuladas = horasActuales + horas
                
                self.db.collection("users").document(userID).updateData([
                    "horasAcumuladas": nuevasHorasAcumuladas
                    // Aquí NO vamos a modificar registeredEventIDs directamente en Firestore.
                    // La lógica de si un evento está "pendiente de horas" o "en historial"
                    // se basa en si existe un RegistroHora para él, no en quitarlo de registeredEventIDs.
                    // Un usuario sigue "registrado" a un evento incluso después de cargar horas.
                ]) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error al actualizar horas acumuladas: \(error.localizedDescription)")
                            // Revertir la actualización optimista de misRegistrosDeHoras si es necesario,
                            // aunque el fetch posterior lo corregirá.
                            self.misRegistrosDeHoras.removeAll(where: { $0.id == nuevoRegistro.id }) // Revierte si el ID de nuevoRegistro es estable
                            completion(false, "Registro guardado, pero error al actualizar horas totales: \(error.localizedDescription)")
                        } else {
                            print("Horas acumuladas actualizadas exitosamente.")
                            // Es crucial recargar AMBOS para asegurar consistencia total con Firestore.
                            self.fetchUserProfile(uid: userID)       // Actualiza userProfile (incluye horasAcumuladas)
                            self.fetchMisRegistrosDeHoras()      // Actualiza la lista de todos los registros
                            completion(true, nil)
                        }
                    }
                }
            }
        } catch {
            print("Error al codificar RegistroHora o preparar la escritura: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false, "Error al preparar los datos del registro: \(error.localizedDescription)")
            }
        }
    }
}
