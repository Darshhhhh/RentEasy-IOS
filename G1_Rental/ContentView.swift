//
//  ContentView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isLoading {
                ProgressView("Loading…")
            } else if let role = authVM.user?.role {
                switch role {
                case "tenant":
                    TenantRootView()
                case "landlord":
                    LandlordRootView()
                case "guest":
                    GuestRootView()
                default:
                    Text("Unknown role: \(role)")
                        .foregroundColor(.red)
                }
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}

