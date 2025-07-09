//
//  AuthViewModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: UserModel?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let authService = AuthService()
    private let dbService   = FirestoreService()
    private var handle: AuthStateDidChangeListenerHandle?

    func listenAuthState() {
        isLoading = true
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let uid = user?.uid {
                self.dbService.fetchUser(uid: uid) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let u): self.user = u
                        case .failure(let e): self.errorMessage = e.localizedDescription
                        }
                        self.isLoading = false
                    }
                }
            } else {
                self.user = nil
                self.isLoading = false
            }
        }
    }
    
    func loginAsGuest() {
        // dummy UserModel with role "guest"
        let guestUser = UserModel(
            uid: UUID().uuidString,
            email: "",
            name: "Guest",
            role: "guest",
            contact: "",
            paymentInfo: ""
        )
        // Immediately show guest UI
        self.user = guestUser
    }

    func signUp(email: String, password: String, name: String, role: String) {
        authService.signUp(email: email, password: password, name: name, role: role) { result in
            DispatchQueue.main.async {
                if case .failure(let e) = result { self.errorMessage = e.localizedDescription }
            }
        }
    }

    func signIn(email: String, password: String, rememberMe: Bool) {
        authService.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    UserDefaultsManager.rememberMe = rememberMe
                    if rememberMe {
                        UserDefaultsManager.savedEmail = email
                        UserDefaultsManager.savedPassword = password
                    } else {
                        UserDefaultsManager.savedEmail = nil
                        UserDefaultsManager.savedPassword = nil
                    }
                case .failure(let e):
                    self?.errorMessage = e.localizedDescription
                }
            }
        }
    }

    func signOut() {
        do { try authService.signOut() }
        catch { errorMessage = error.localizedDescription }
    }
}
