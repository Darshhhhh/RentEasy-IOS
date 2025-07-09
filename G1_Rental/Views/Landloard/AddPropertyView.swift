//
//  AddPropertyView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI
import CoreLocation

struct AddPropertyView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var authVM: AuthViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var address = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    private let service = FirestoreService()

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                Section("Location") {
                    TextField("Address", text: $address)
                    TextField("Latitude", text: $latitude)
                    TextField("Longitude", text: $longitude)
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let uid = authVM.user?.uid else { return }
                        let prop = PropertyModel(
                            id: UUID().uuidString,
                            ownerId: uid,
                            title: title,
                            description: description,
                            address: address,
                            latitude: Double(latitude),
                            longitude: Double(longitude),
                            isListed: true,
                            createdAt: Date()
                        )
                        service.addProperty(prop) { _ in
                            presentation.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
            }
        }
    }
}
