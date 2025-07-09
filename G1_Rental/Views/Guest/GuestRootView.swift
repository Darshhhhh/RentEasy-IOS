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
            Button {
                authVM.user = nil
            } label: {
                Label("Log in to make inquiries", systemImage: "person.crop.circle.badge.questionmark")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal)
               
        }
    }
}
