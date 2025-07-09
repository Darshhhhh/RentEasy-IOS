//
//  G1_RentalApp.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//

import SwiftUI
import Firebase

@main
struct G1_RentalAppApp: App {
  @StateObject private var authVM = AuthViewModel()

  init() { FirebaseApp.configure() }

  var body: some Scene {
    WindowGroup {
      Group {
        if authVM.isLoading {
          ProgressView("Loading…")
        } else if authVM.user == nil {
          NavigationStack {
            LoginView()
              .environmentObject(authVM)
          }
        } else {
          ContentView()
            .environmentObject(authVM)
        }
      }
      .onAppear { authVM.listenAuthState() }
    }
  }
}
