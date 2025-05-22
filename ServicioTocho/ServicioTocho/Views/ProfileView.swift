//
//  ProfileView.swift
//  ServicioTocho
//
//  Created by CETYS Universidad  on 14/05/25.
//
import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    let todosLosEventos: [Evento] = mockEventos

    // Eventos unidos para los cuales aun no se han registrado horas
    var eventosParaRegistrarHoras: [Evento] {
        print("ProfileView: Calculando eventosParaRegistrarHoras...")
        guard let profile = authViewModel.userProfile,
              let registeredIDs = profile.registeredEventIDs else {
            print("ProfileView: No hay perfil o registeredIDs, devolviendo lista vacía para registrar.")
            return []
        }
        
        let idsEventosConHorasRegistradas = Set(authViewModel.misRegistrosDeHoras.compactMap { $0.idEvento })
        print("ProfileView: IDs de eventos registrados por el usuario (UserProfile): \(registeredIDs)")
        print("ProfileView: IDs de eventos con horas ya logueadas (misRegistrosDeHoras): \(idsEventosConHorasRegistradas)")
        
        let eventosFiltrados = todosLosEventos.filter { evento in
            guard let eventoID = evento.id else { return false }
            let estaRegistrado = registeredIDs.contains(eventoID)
            let yaLogueoHoras = idsEventosConHorasRegistradas.contains(eventoID)
            return estaRegistrado && !yaLogueoHoras
        }
        print("ProfileView: eventosParaRegistrarHoras count: \(eventosFiltrados.count)")
        return eventosFiltrados
    }
    
    // Helper para obtener el Evento dado un ID de evento desde RegistroHora
    func getEvento(byId eventoId: String?) -> Evento? {
        guard let eventoId = eventoId else { return nil }
        return todosLosEventos.first { $0.id == eventoId }
    }

    var body: some View {
        let _ = print("ProfileView: Body re-evaluado. MisRegistrosDeHoras count: \(authViewModel.misRegistrosDeHoras.count), UserProfile.registeredEventIDs count: \(authViewModel.userProfile?.registeredEventIDs?.count ?? 0)")
        ZStack {
            Color.appBackground.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 30) {
                    // Sección del Cabezal del Perfil
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable().scaledToFit().frame(width: 100, height: 100)
                            .foregroundColor(Color.accentColorTeal.opacity(0.7)).padding(.top, 20)
                        if let nombreComp = authViewModel.nombreCompletoForProfile() {
                            Text(nombreComp).font(.title2).fontWeight(.bold)
                        } else { Text("Nombre no disponible").font(.title2).fontWeight(.medium) }
                        if let email = authViewModel.emailForProfile() {
                            Text(email).font(.callout).foregroundColor(.gray)
                        }
                    }.padding(.bottom, 10)

                    // Tarjeta de Detalles del Usuario (Horas Acumuladas)
                    VStack(alignment: .leading, spacing: 18) {
                        DetailRow(iconName: "hourglass.circle.fill",
                                  label: "Horas Acumuladas",
                                  value: String(format: "%.1f", authViewModel.userProfile?.horasAcumuladas ?? 0.0))
                    }
                    .padding(20).background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15).shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    NavigationLink(destination: HorasReportView(authViewModel: authViewModel, todosLosEventos: todosLosEventos)) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                                .foregroundColor(Color.accentColorTeal)
                                            Text("Generar Reporte de Horas")
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary.opacity(0.7))
                                        }
                                        .padding()
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }

                    // Eventos para Registrar Horas
                    if !eventosParaRegistrarHoras.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Eventos para Registrar Horas")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundColor(Color.primary)
                                .padding(.horizontal)

                            ForEach(eventosParaRegistrarHoras) { evento in
                                NavigationLink(destination: LogHoursView(evento: evento, authViewModel: authViewModel)) {
                                    MiniEventoRow(evento: evento, conIconoChevron: true)
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else if authViewModel.userIsLoggedIn && authViewModel.misRegistrosDeHoras.isEmpty && authViewModel.userProfile?.registeredEventIDs?.isEmpty ?? true {
                        // Solo muestra este mensaje si no hay nada en ninguna lista de eventos y está logueado
                        Text("Aún no te has unido a ningún evento.")
                           .foregroundColor(.secondary)
                           .padding()
                    }
                    
                    // Historial de Participación
                    if !authViewModel.misRegistrosDeHoras.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Historial de Participación")
                                .font(.title3).fontWeight(.semibold)
                                .foregroundColor(Color.primary)
                                .padding([.horizontal, .top])

                            ForEach(authViewModel.misRegistrosDeHoras) { registroHora in
                                if let eventoAsociado = getEvento(byId: registroHora.idEvento) {
                                    NavigationLink(destination: RegistroDetalleView(registroHora: registroHora, evento: eventoAsociado)) {
                                        HistorialEventoRow(evento: eventoAsociado, registroHora: registroHora)
                                    }
                                    .padding(.horizontal)
                                } else {
                                    Text("Detalles de evento no disponibles para un registro.")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    } else if authViewModel.userIsLoggedIn && !eventosParaRegistrarHoras.isEmpty {
                        // Si hay eventos para registrar horas, pero no hay historial.
                        Text("Aún no has registrado horas para tus eventos unidos.")
                            .foregroundColor(.secondary)
                            .padding()
                    }


                    Spacer(minLength: 30)
                    Button(action: { authViewModel.signOut() }) {
                        HStack {
                            Image(systemName: "arrow.left.square.fill")
                            Text("Cerrar Sesión")
                        }
                        .fontWeight(.semibold).frame(maxWidth: .infinity).padding()
                        .background(Color.red.opacity(0.9)).foregroundColor(.white)
                        .cornerRadius(10).shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding([.horizontal, .bottom])
                }
            }
        }
        .navigationTitle("Mi Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
                print("ProfileView: .onAppear disparado.")
                if authViewModel.userProfile == nil, let uid = authViewModel.currentUser()?.uid {
                    print("ProfileView: .onAppear - userProfile es nil, llamando a fetchUserProfile.")
                    authViewModel.fetchUserProfile(uid: uid)
                }
                print("ProfileView: .onAppear - llamando a fetchMisRegistrosDeHoras.")
                authViewModel.fetchMisRegistrosDeHoras()
            }
    }
}


struct MiniEventoRow: View {
    let evento: Evento
    var conIconoChevron: Bool = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(evento.nombre)
                    .font(.headline)
                    .foregroundColor(Color.primary)
                    .lineLimit(1)
                Text("Fecha: \(evento.fechaInicio, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if conIconoChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// Subvista para mostrar un evento en el historial de participación
struct HistorialEventoRow: View {
    let evento: Evento
    let registroHora: RegistroHora

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(evento.nombre)
                    .font(.headline)
                    .foregroundColor(Color.primary)
                Text("Horas Registradas: \(String(format: "%.1f", registroHora.horasReportadas))")
                    .font(.subheadline)
                    .foregroundColor(Color.accentColorTeal)
                Text("Fecha de Registro: \(registroHora.fecha, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct DetailRow: View {
    var iconName: String
    var label: String
    var value: String
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName).font(.title3).foregroundColor(Color.accentColorTeal).frame(width: 30, alignment: .center)
            VStack(alignment: .leading) {
                Text(label).font(.caption).foregroundColor(.secondary)
                Text(value).font(.body).fontWeight(.medium).foregroundColor(Color.primary)
            }
            Spacer()
        }
    }
}
