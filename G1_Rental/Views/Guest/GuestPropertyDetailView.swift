//
//  GuestPropertyDetailView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI
import MapKit

struct GuestPropertyDetailView: View {
    let property: PropertyModel

    var body: some View {
        VStack(spacing: 16) {
            Text(property.title)
                .font(.largeTitle)
                .bold()

            Text(property.description)
                .padding(.vertical)

            Text(property.address)
                .foregroundColor(.secondary)

            if let lat = property.latitude,
               let lon = property.longitude {
                MapView(
                    coordinate: CLLocationCoordinate2D(
                        latitude: lat,
                        longitude: lon
                    )
                )
                .frame(height: 200)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Details")
    }
}
