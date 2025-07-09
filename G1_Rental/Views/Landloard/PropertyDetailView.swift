//
//  PropertyDetailView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI
import MapKit

struct PropertyDetailView: View {
    let property: PropertyModel
    @State private var editing = false
    @EnvironmentObject var authVM: AuthViewModel
    @State private var title: String
    @State private var description: String
    @State private var address: String
    @State private var latitude: String
    @State private var longitude: String
    private let service = FirestoreService()
    @Environment(\.presentationMode) var presentation

    init(property: PropertyModel) {
        self.property = property
        _title       = State(initialValue: property.title)
        _description = State(initialValue: property.description)
        _address     = State(initialValue: property.address)
        _latitude  = State(initialValue: property.latitude.map { String($0) } ?? "")
        _longitude = State(initialValue: property.longitude.map { String($0) } ?? "")
    }

    
    var body: some View {
        VStack(spacing: 16) {
            if editing {
                Form {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Address", text: $address)
                    TextField("Latitude", text: $latitude)
                    TextField("Longitude", text: $longitude)
                }
            } else {
                Text(property.title).font(.largeTitle)
                Text(property.description)
                Text(property.address).foregroundColor(.secondary)
                if let lat = property.latitude, let lon = property.longitude {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        .frame(height: 200)
                }
            }

            Spacer()

            HStack {
                Button(editing ? "Update" : "Edit") {
                    if editing {
                        var updated = property
                        updated = PropertyModel(
                            id: property.id,
                            ownerId: property.ownerId,
                            title: title,
                            description: description,
                            address: address,
                            latitude: Double(latitude),
                            longitude: Double(longitude),
                            isListed: property.isListed,
                            createdAt: property.createdAt
                        )
                        service.updateProperty(updated) { _ in
                            editing = false
                        }
                    } else {
                        editing = true
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Delete", role: .destructive) {
                    service.deleteProperty(property) { _ in
                        presentation.wrappedValue.dismiss()
                    }
                }
            }
        }
        .padding()
    }
}
