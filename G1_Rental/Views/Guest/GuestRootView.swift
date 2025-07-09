//
//  GuestRootView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//

import SwiftUI

struct GuestRootView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            GuestDashboardView()
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Sign In Now") {
                            // Clear out the guest and return to login
                            authVM.user = nil
                        }
                        .foregroundColor(.blue)
                    }
                }
        }
    }
}
