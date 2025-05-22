//
//  AuthenticationViewModel.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import PDFKit
import UIKit

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
            }
        }
    }

    // Función para cargar el perfil del usuario desde Firestore
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
                        self.userProfile = try document.data(as: UserProfile.self)
                        print("Perfil de usuario cargado: \(self.userProfile?.nombreCompleto ?? "N/A")")
                        print("Eventos registrados: \(self.userProfile?.registeredEventIDs ?? [])")
                    } catch {
                        print("Error al decodificar perfil de usuario: \(error.localizedDescription)")
                        self.errorMessage = "Error al leer datos del perfil."
                        self.userProfile = nil
                    }
                } else {
                    print("Documento de perfil no existe en Firestore para UID: \(uid).")
                    self.errorMessage = "Perfil de usuario no encontrado en la base de datos."
                    self.userProfile = nil
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
                        }
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error al preparar datos del perfil: \(error.localizedDescription)"
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
            try Auth.auth().signOut()
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
            
            return
        }

        db.collection("registros_horas")
          .whereField("idUsuario", isEqualTo: userID)
          .order(by: "fecha", descending: true)
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

        // Crear el objeto RegistroHora
        let nuevoRegistro = RegistroHora(
            idEvento: eventoID,
            idUsuario: userID,
            fecha: Date(), // Fecha actual del registro
            horasReportadas: horas,
            aprobado: true, // Auto-aprobado por ahora
            descripcionActividad: descripcion
        )

        // Guardar el RegistroHora en Firestore (nueva colección "registros_horas")
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

                DispatchQueue.main.async {
                                // Creamos una nueva copia del array, añadimos el nuevo registro,
                                // y luego reasignamos la propiedad @Published.
                                var nuevosRegistros = self.misRegistrosDeHoras
                                nuevosRegistros.append(nuevoRegistro)
                                self.misRegistrosDeHoras = nuevosRegistros
                                print("ViewModel: misRegistrosDeHoras actualizado localmente (optimista). Nuevo count: \(self.misRegistrosDeHoras.count)")
                            }


                // Actualizar horasAcumuladas en UserProfile en Firestore
                // Obtenemos las horas acumuladas actuales del userProfile local o volvemos a pedirlas.
                let horasActuales = self.userProfile?.horasAcumuladas ?? 0.0
                let nuevasHorasAcumuladas = horasActuales + horas
                
                self.db.collection("users").document(userID).updateData([
                    "horasAcumuladas": nuevasHorasAcumuladas
                    // La lógica de si un evento está "pendiente de horas" o "en historial"
                    // se basa en si existe un RegistroHora para él, no en quitarlo de registeredEventIDs.
                    // Un usuario sigue "registrado" a un evento incluso después de cargar horas.
                ]) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error al actualizar horas acumuladas: \(error.localizedDescription)")
                            // Revertir la actualización optimista de misRegistrosDeHoras si es necesario
                            self.misRegistrosDeHoras.removeAll(where: { $0.id == nuevoRegistro.id }) // Revierte si el ID de nuevoRegistro es estable
                            completion(false, "Registro guardado, pero error al actualizar horas totales: \(error.localizedDescription)")
                        } else {
                            print("Horas acumuladas actualizadas exitosamente.")
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
    
    func generarReportePDFDatos(eventos todosLosEventos: [Evento]) -> Data? {
        guard let userProfile = self.userProfile, !self.misRegistrosDeHoras.isEmpty else {
            print("Perfil de usuario o registros de horas no disponibles para PDF.")
            return nil
        }

        let pdfMetaData = [
            kCGPDFContextCreator: "VoluntariadoApp",
            kCGPDFContextAuthor: userProfile.nombreCompleto,
            kCGPDFContextTitle: "Reporte de Horas de Servicio Social"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth: CGFloat = 8.27 * 72.0
        let pageHeight: CGFloat = 11.69 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let margin: CGFloat = 0.75 * 72.0
        let contentWidth = pageWidth - (2 * margin)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            var currentPage = 0
            var yPosition: CGFloat = margin

            // Función para dibujar encabezado de página
            let drawPageHeader = {
                yPosition = margin // Reiniciar Y para cada nueva página

                let reportTitle = "Reporte de Horas de Servicio Social"
                let titleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
                let reportTitleSize = reportTitle.size(withAttributes: [.font: titleFont])
                reportTitle.draw(at: CGPoint(x: (pageWidth - reportTitleSize.width) / 2, y: yPosition),
                                 withAttributes: [.font: titleFont, .foregroundColor: UIColor.black])
                yPosition += reportTitleSize.height + 20

                let studentInfoFont = UIFont.systemFont(ofSize: 12)
                let studentName = "Estudiante: \(userProfile.nombreCompleto)"
                studentName.draw(at: CGPoint(x: margin, y: yPosition),
                                 withAttributes: [.font: studentInfoFont, .foregroundColor: UIColor.darkGray])
                yPosition += studentName.size(withAttributes: [.font: studentInfoFont]).height + 5

                let studentEmail = "Correo: \(userProfile.email)"
                studentEmail.draw(at: CGPoint(x: margin, y: yPosition),
                                  withAttributes: [.font: studentInfoFont, .foregroundColor: UIColor.darkGray])
                yPosition += studentEmail.size(withAttributes: [.font: studentInfoFont]).height + 5

                let totalHours = "Total Horas Aprobadas: \(String(format: "%.1f", userProfile.horasAcumuladas))"
                totalHours.draw(at: CGPoint(x: margin, y: yPosition),
                                withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .semibold), .foregroundColor: UIColor.black])
                yPosition += totalHours.size(withAttributes: [.font: studentInfoFont]).height + 15

                // Línea divisora
                context.cgContext.move(to: CGPoint(x: margin, y: yPosition))
                context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
                context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                context.cgContext.strokePath()
                yPosition += 15
            }

            // Función para dibujar pie de página
            let drawPageFooter = { (pageNum: Int) in
                let footerFont = UIFont.systemFont(ofSize: 9)
                let pageText = "Página \(pageNum)"
                let pageSize = pageText.size(withAttributes: [.font: footerFont])
                pageText.draw(at: CGPoint(x: pageWidth - margin - pageSize.width, y: pageHeight - margin + 10),
                              withAttributes: [.font: footerFont, .foregroundColor: UIColor.gray])
            }


            // Iniciar la primera página
            context.beginPage()
            currentPage += 1
            drawPageHeader()
            drawPageFooter(currentPage)


            let entryFont = UIFont.systemFont(ofSize: 11)
            let entryBoldFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
            let entrySpacing: CGFloat = 20 // Espacio entre entradas de registro

            for registro in self.misRegistrosDeHoras {
                guard let evento = todosLosEventos.first(where: { $0.id == registro.idEvento }) else { continue }

                var entryHeightEstimate: CGFloat = 0
                let eventNameText = "Evento: \(evento.nombre)"
                let eventNameAttrString = NSAttributedString(string: eventNameText, attributes: [.font: entryBoldFont])
                entryHeightEstimate += eventNameAttrString.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height

                let hoursText = "Horas Reportadas: \(String(format: "%.1f", registro.horasReportadas))"
                let hoursAttrString = NSAttributedString(string: hoursText, attributes: [.font: entryFont])
                entryHeightEstimate += hoursAttrString.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height + 3

                if let desc = registro.descripcionActividad, !desc.isEmpty {
                    let descText = "Actividad: \(desc)"
                    let descAttrString = NSAttributedString(string: descText, attributes: [.font: entryFont])
                    entryHeightEstimate += descAttrString.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height + 3
                }
                entryHeightEstimate += 10 // Padding inferior para la entrada

                // Comprobar si necesitamos una nueva página
                if yPosition + entryHeightEstimate > (pageHeight - margin - 20) {
                    context.beginPage()
                    currentPage += 1
                    drawPageHeader()
                    drawPageFooter(currentPage)
                }

                // Dibujar Nombre del Evento
                eventNameAttrString.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: 100)) 
                yPosition += eventNameAttrString.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height + 3

                // Dibujar Horas
                hoursAttrString.draw(at: CGPoint(x: margin, y: yPosition))
                yPosition += hoursAttrString.size().height + 3

                // Dibujar Descripción
                if let desc = registro.descripcionActividad, !desc.isEmpty {
                    let descText = "Actividad: \(desc)"
                    let descAttrString = NSAttributedString(string: descText, attributes: [.font: entryFont])
                    let descRect = descAttrString.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
                    descAttrString.draw(in: CGRect(x: margin, y: yPosition, width: contentWidth, height: descRect.height))
                    yPosition += descRect.height + 3
                }
                yPosition += entrySpacing // Espacio antes del siguiente evento
            }
        }
        return data
    }
}
