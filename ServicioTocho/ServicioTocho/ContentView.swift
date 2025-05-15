//
//  ContentView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI

struct ContentView: View {
    // ContentView ahora también necesita un AuthenticationViewModel para pasárselo a EventosListView
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some View {
        // Pasamos la instancia de authViewModel a EventosListView
        EventosListView(authViewModel: authViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
