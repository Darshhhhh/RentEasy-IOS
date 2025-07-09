//
//  LandlordRootView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct LandlordRootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            NavigationStack {
                LandlordDashboardView()
                    .environmentObject(authVM)
            }
            .tabItem {
                Label("Properties", systemImage: "building.2")
            }

            NavigationStack {
                RequestsListView()
                    .environmentObject(authVM)
            }
            .tabItem {
                Label("Requests", systemImage: "envelope")
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

