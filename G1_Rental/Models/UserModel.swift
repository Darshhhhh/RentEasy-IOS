//
//  UserModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

struct UserModel: Identifiable {
    let uid: String
    var email: String
    var name: String
    var role: String   // "landlord", "tenant", or "guest"
    var contact: String
    var cardNumber: String

    // satisfy Identifiable
    var id: String { uid }
}
