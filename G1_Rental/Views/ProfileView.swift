//
//  ProfileView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name = ""
    @State private var contact = ""
    @State private var payment = ""
    private let service = FirestoreService()

    var body: some View {
        VStack(spacing: 20) {
            Text("Profile").font(.title)
            TextField("Name", text: $name)
                .padding()
                .background(Color(.secondarySystemBackground))
            TextField("Contact", text: $contact)
                .padding()
                .background(Color(.secondarySystemBackground))
            TextField("Payment Info", text: $payment)
                .padding()
                .background(Color(.secondarySystemBackground))
            Button("Save") {
                guard let u = authVM.user else { return }
                let updated = UserModel(
                    uid: u.uid,
                    email: u.email,
                    name: name,
                    role: u.role,
                    contact: contact,
                    paymentInfo: payment
                )
                service.updateUserProfile(updated) { _ in authVM.listenAuthState() }
            }
            Button("Logout", role: .destructive) {
                authVM.signOut()
            }
        }
        .padding()
        .onAppear {
            if let u = authVM.user {
                name = u.name
                contact = u.contact
                payment = u.paymentInfo
            }
        }
    }
}
