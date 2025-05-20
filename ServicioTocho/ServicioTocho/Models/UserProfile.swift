//
//  UserProfile.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 19/05/25.
//


import FirebaseFirestoreSwift // Necesario para @DocumentID y Codable con Firestore

struct UserProfile: Identifiable, Codable, Equatable { // Equatable para @Published en ViewModel si es necesario
    @DocumentID var id: String? // El UID de Firebase Auth se usará como ID del documento
    var username: String
    var email: String
    var registeredEventIDs: [String]? // Array de IDs de los eventos a los que el usuario se ha unido

    // Inicializador para cuando creamos un nuevo perfil
    init(id: String? = nil, username: String, email: String, registeredEventIDs: [String]? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.registeredEventIDs = registeredEventIDs ?? [] // Inicializar como array vacío si es nil
    }
}