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

    @State private var title       = ""
    @State private var description = ""
    @State private var address     = ""
    @State private var isSaving    = false
    @State private var errorMessage: String?

    private let geocoder = CLGeocoder()
    private let service  = FirestoreService()

    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }

                Section("Location") {
                    TextField("Address", text: $address)
                }

                if let msg = errorMessage {
                    Section {
                        Text(msg)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveProperty()
                        }
                        .disabled(title.isEmpty || address.isEmpty)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentation.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func saveProperty() {
        guard let uid = authVM.user?.uid else { return }
        isSaving = true
        errorMessage = nil

        geocoder.geocodeAddressString(address) { placemarks, error in
            DispatchQueue.main.async {
                isSaving = false

                if let error = error {
                    errorMessage = "Geocoding error: \(error.localizedDescription)"
                    return
                }
                guard let loc = placemarks?.first?.location else {
                    errorMessage = "Can't find that address."
                    return
                }

                let prop = PropertyModel(
                    id: UUID().uuidString,
                    ownerId: uid,
                    title: title,
                    description: description,
                    address: address,
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude,
                    isListed: true,
                    createdAt: Date()
                )

                service.addProperty(prop) { err in
                    DispatchQueue.main.async {
                        if let err = err {
                            errorMessage = "Save failed: \(err.localizedDescription)"
                        } else {
                            presentation.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

