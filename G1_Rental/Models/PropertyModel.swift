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
    var title: String
    var description: String
    var address: String
    var latitude: Double?
    var longitude: Double?
    var monthlyRent: Double
    var bedrooms: Int
    var squareFootage: Double
    var bathrooms: Double
    var contactInfo: String
    var availableFrom: Date
    var isListed: Bool
    let createdAt: Date
}
