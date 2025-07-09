//
//  PropertyModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

struct PropertyModel: Identifiable {
    let id: String
    let ownerId: String
    let title: String
    let description: String
    let address: String
    let latitude: Double?
    let longitude: Double?
    let isListed: Bool
    let createdAt: Date
}
