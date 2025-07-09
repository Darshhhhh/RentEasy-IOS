//
//  SignupView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role = "tenant"
    private let roles = ["tenant", "landlord"]

    var body: some View {
        Form {
            Section(header: Text("Account")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                Picker("Role", selection: $role) {
                    ForEach(roles, id: \.self) { Text($0.capitalized) }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Button("Sign Up") {
                authVM.signUp(email: email, password: password, name: name, role: role)
            }
            if let err = authVM.errorMessage {
                Text(err).foregroundColor(.red)
            }
        }
        .navigationTitle("Create Account")
    }
}
