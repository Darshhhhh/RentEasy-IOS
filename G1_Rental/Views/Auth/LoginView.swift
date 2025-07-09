//
//  LoginView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email      = UserDefaultsManager.savedEmail ?? ""
    @State private var password   = UserDefaultsManager.savedPassword ?? ""
    @State private var rememberMe = UserDefaultsManager.rememberMe
    
    var body: some View {
        // ← no extra NavigationStack here since App already provides one
        VStack(spacing: 20) {
            Text("G1 RentalApp").font(.largeTitle).bold()
            
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
            
            Toggle("Remember Me", isOn: $rememberMe)
            
            if let err = authVM.errorMessage {
                Text(err).foregroundColor(.red)
            }
            
            Button("Login") {
                authVM.signIn(email: email, password: password, rememberMe: rememberMe)
            }
            Button("Continue as Guest") {
                authVM.loginAsGuest()
            }
            .foregroundColor(.blue)
            .underline()
            .padding(.top)
            
            NavigationLink {
                SignupView()
                    .environmentObject(authVM)
            } label: {
                Text("Sign Up")
                    .underline()
            }
            .padding(.top)
        }
        .padding()
        .navigationTitle("Login")
    }
}
