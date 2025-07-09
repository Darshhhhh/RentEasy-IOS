//
//  ShortlistModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

struct ShortlistModel: Identifiable {
    let id: String
    let tenantId: String
    let propertyId: String
    let createdAt: Date
}
