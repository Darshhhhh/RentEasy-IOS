//
//  LoginView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-10.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email      = UserDefaultsManager.savedEmail ?? ""
    @State private var password   = UserDefaultsManager.savedPassword ?? ""
    @State private var rememberMe = UserDefaultsManager.rememberMe

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App Title
            HStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                Text("G1 RentalApp")
                    .font(.largeTitle)
                    .bold()
            }

            // Input Fields
            VStack(spacing: 16) {
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
            }
            .padding(.horizontal)

            // Remember Me
            Toggle(isOn: $rememberMe) {
                Text("Remember Me")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Error Message
            if let err = authVM.errorMessage {
                Text(err)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Action Buttons
            VStack(spacing: 16) {
                Button(action: {
                    authVM.signIn(email: email, password: password, rememberMe: rememberMe)
                }) {
                    Label("Login", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                NavigationLink {
                    SignupView()
                        .environmentObject(authVM)
                } label: {
                    Label("Sign Up", systemImage: "person.badge.plus.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Button(action: {
                    authVM.loginAsGuest()
                }) {
                    Label("Continue as Guest", systemImage: "person.crop.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.inline)
    }
}
