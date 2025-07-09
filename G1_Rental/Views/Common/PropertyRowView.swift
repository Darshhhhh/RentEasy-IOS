//
//  PropertyRowView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct PropertyRowView: View {
    let property: PropertyModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(property.title).font(.headline)
            Text(property.address).font(.subheadline).foregroundColor(.secondary)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke())
    }
}
