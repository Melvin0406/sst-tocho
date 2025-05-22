//
//  UserProfile.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 19/05/25.
//


import FirebaseFirestore 

struct UserProfile: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var nombreCompleto: String
    var email: String
    var horasAcumuladas: Double = 0.0
    var registeredEventIDs: [String]? = []

    init(id: String? = nil,
         nombreCompleto: String,
         email: String,
         horasAcumuladas: Double = 0.0,
         registeredEventIDs: [String]? = nil) {
        self.id = id
        self.nombreCompleto = nombreCompleto
        self.email = email
        self.horasAcumuladas = horasAcumuladas
        self.registeredEventIDs = registeredEventIDs ?? []
    }
}
