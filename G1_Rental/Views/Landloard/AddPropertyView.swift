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

    @State private var title         = ""
    @State private var description   = ""
    @State private var address       = ""
    @State private var monthlyRent   = ""
    @State private var bedrooms      = ""
    @State private var squareFootage = ""
    @State private var bathrooms     = ""
    @State private var contactInfo   = ""
    @State private var availableFrom = Date()

    @State private var isSaving      = false
    @State private var errorMessage: String?

    private let geocoder = CLGeocoder()
    private let service  = FirestoreService()

    var body: some View {
        NavigationView {
            Form {
                Section("Basic") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Address", text: $address)
                }

                Section("Financial") {
                    TextField("Monthly Rent", text: $monthlyRent)
                        .keyboardType(.decimalPad)
                }

                Section("Details") {
                    TextField("Bedrooms", text: $bedrooms)
                        .keyboardType(.numberPad)
                    TextField("Square Footage", text: $squareFootage)
                        .keyboardType(.decimalPad)
                    TextField("Bathrooms", text: $bathrooms)
                        .keyboardType(.decimalPad)
                }

                Section("Contact & Availability") {
                    TextField("Contact Info", text: $contactInfo)
                    DatePicker("Available From", selection: $availableFrom, displayedComponents: .date)
                }

                if let msg = errorMessage {
                    Section { Text(msg).foregroundColor(.red) }
                }
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { saveProperty() }
                            .disabled(title.isEmpty || address.isEmpty)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentation.wrappedValue.dismiss() }
                }
            }
        }
    }

    private func saveProperty() {
        guard let uid = authVM.user?.uid else { return }
        isSaving = true
        errorMessage = nil

        // Validate numeric fields
        guard
            let rent  = Double(monthlyRent),
            let beds  = Int(bedrooms),
            let sqft  = Double(squareFootage),
            let baths = Double(bathrooms)
        else {
            errorMessage = "Please enter valid numbers."
            isSaving = false
            return
        }

        geocoder.geocodeAddressString(address) { placemarks, error in
            DispatchQueue.main.async {
                isSaving = false
                if let error = error {
                    errorMessage = "Geocode error: \(error.localizedDescription)"
                    return
                }
                guard let loc = placemarks?.first?.location else {
                    errorMessage = "Address not found."
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

                    // new
                    monthlyRent:   rent,
                    bedrooms:      beds,
                    squareFootage: sqft,
                    bathrooms:     baths,
                    contactInfo:   contactInfo,
                    availableFrom: availableFrom,

                    isListed:      true,
                    createdAt:     Date()
                )

                service.addProperty(prop) { err in
                    DispatchQueue.main.async {
                        if let err = err {
                            errorMessage = err.localizedDescription
                        } else {
                            presentation.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}


