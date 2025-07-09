//
//  RequestModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

struct RequestModel: Identifiable {
    let id: String
    let propertyId: String
    let ownerId: String
    let tenantId: String
    var status: String       // "pending", "approved", "denied"
    let createdAt: Date
}
