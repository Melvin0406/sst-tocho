//
//  ServicioTochoApp.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI
import FirebaseCore // Importa FirebaseCore

@main
struct ServicioTochoApp: App {
    // Registra el AppDelegate para la configuración de Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
            WindowGroup {
                AuthManagerView() // Esta es la vista que ahora gestiona el flujo
            }
        }
}

// Crea un AppDelegate para configurar Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Configura Firebase
        return true
    }
}
