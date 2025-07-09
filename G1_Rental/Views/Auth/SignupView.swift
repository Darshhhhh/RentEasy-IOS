//
//  SignupView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


//
//  SignupView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-10.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var name     = ""
    @State private var email    = ""
    @State private var password = ""
    @State private var role     = "tenant"
    private let roles = ["tenant", "landlord"]
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            HStack(spacing: 12) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
            }

            // Input fields
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                    TextField("Name", text: $name)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

                Picker("Role", selection: $role) {
                    ForEach(roles, id: \.self) { Text($0.capitalized) }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top)
            }
            .padding(.horizontal)

            // Error message
            if let err = authVM.errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Action buttons
            VStack(spacing: 16) {
                Button {
                    authVM.signUp(email: email, password: password, name: name, role: role)
                } label: {
                    Label("Sign Up", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                NavigationLink {
                    LoginView()
                        .environmentObject(authVM)
                } label: {
                    Label("Back to Login", systemImage: "arrow.left.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
    }
}
