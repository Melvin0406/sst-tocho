//
//  ContentView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 12/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some View {
        EventosListView(authViewModel: authViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
