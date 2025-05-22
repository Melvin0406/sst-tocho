//
//  AuthManagerView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//

import SwiftUI

struct AuthManagerView: View {
    @StateObject private var authViewModel = AuthenticationViewModel()

    var body: some View {
        
        if authViewModel.userIsLoggedIn {
            EventosListView(authViewModel: authViewModel)
        } else {
            LoginView(authViewModel: authViewModel)
        }
    }
}

struct AuthManagerView_Previews: PreviewProvider {
    static var previews: some View {
        AuthManagerView()
    }
}
