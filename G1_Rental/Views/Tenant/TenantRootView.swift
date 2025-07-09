//
//  TenantRootView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct TenantRootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            NavigationStack {
                TenantDashboardView()
                    .environmentObject(authVM)
            }
            .tabItem {
                Label("Browse", systemImage: "magnifyingglass")
            }

            NavigationStack {
                ShortlistView()
                    .environmentObject(authVM)
            }
            .tabItem {
                Label("Shortlist", systemImage: "star")
            }

            NavigationStack {
                ProfileView()
                    .environmentObject(authVM)
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
