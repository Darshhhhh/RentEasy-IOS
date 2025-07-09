//
//  AuthService.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()

    func signUp(email: String, password: String, name: String, role: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { res, err in
            if let err = err { return completion(.failure(err)) }
            guard let uid = res?.user.uid else { return }
            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "name": name,
                "role": role,
                "contact": "",
                "paymentInfo": ""
            ]
            self.db.collection(Constants.usersCollection).document(uid).setData(data) { err in
                if let err = err { return completion(.failure(err)) }
                completion(.success(()))
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { _, err in
            if let err = err { return completion(.failure(err)) }
            completion(.success(()))
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    var currentUserUID: String? {
        auth.currentUser?.uid
    }
}
