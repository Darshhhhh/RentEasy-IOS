//
//  PropertyDetailView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-10.
//

import SwiftUI
import MapKit

struct PropertyDetailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentation

    let property: PropertyModel
    @State private var isEditing           = false

    // Editable fields
    @State private var titleText           : String
    @State private var descriptionText     : String
    @State private var addressText         : String
    @State private var monthlyRentText     : String
    @State private var bedroomsText        : String
    @State private var squareFootageText   : String
    @State private var bathroomsText       : String
    @State private var contactInfoText     : String
    @State private var availableFrom       : Date

    @State private var showDeleteConfirmation = false
    @State private var showUpdateSuccess      = false

    private let service = FirestoreService()

    init(property: PropertyModel) {
        self.property            = property
        _titleText               = State(initialValue: property.title)
        _descriptionText         = State(initialValue: property.description)
        _addressText             = State(initialValue: property.address)
        _monthlyRentText         = State(initialValue: String(property.monthlyRent))
        _bedroomsText            = State(initialValue: String(property.bedrooms))
        _squareFootageText       = State(initialValue: String(property.squareFootage))
        _bathroomsText           = State(initialValue: String(property.bathrooms))
        _contactInfoText         = State(initialValue: property.contactInfo)
        _availableFrom           = State(initialValue: property.availableFrom)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Map
                if let lat = property.latitude,
                   let lon = property.longitude {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                // Data fields
                VStack(alignment: .leading, spacing: 20) {
                    fieldRow(icon: "textformat", label: "Title", content: $titleText)
                    fieldRow(icon: "doc.text", label: "Description", content: $descriptionText)
                    fieldRow(icon: "mappin.and.ellipse", label: "Address", content: $addressText)
                    fieldRow(icon: "dollarsign.circle", label: "Monthly Rent", content: $monthlyRentText)
                    fieldRow(icon: "bed.double.fill",  label: "Bedrooms",     content: $bedroomsText)
                    fieldRow(icon: "ruler",            label: "Square Footage",content: $squareFootageText)
                    fieldRow(icon: "bathtub.fill",     label: "Bathrooms",    content: $bathroomsText)
                    fieldRow(icon: "phone.fill",       label: "Contact Info", content: $contactInfoText)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Available From")
                                .font(.headline)
                        }
                        if isEditing {
                            DatePicker("", selection: $availableFrom, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        } else {
                            Text(availableFrom, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        if isEditing { saveChanges() }
                        else        { isEditing = true }
                    } label: {
                        Label(isEditing ? "Save Changes" : "Edit Property",
                              systemImage: isEditing ? "square.and.arrow.down" : "square.and.pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Property", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Property Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Are you sure you want to delete this property?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteProperty()
            }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Property updated successfully", isPresented: $showUpdateSuccess) {
            Button("OK", role: .cancel) { }
        }
    }

    // Helper to draw a label + textfield/text
    private func fieldRow(icon: String, label: String, content: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
                    .font(.headline)
            }
            if isEditing {
                TextField(label, text: content)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(content.wrappedValue)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func saveChanges() {
        // Validate numeric inputs
        guard
            let rent  = Double(monthlyRentText),
            let beds  = Int(bedroomsText),
            let sqft  = Double(squareFootageText),
            let baths = Double(bathroomsText)
        else { return }

        let updated = PropertyModel(
            id: property.id,
            ownerId: property.ownerId,
            title: titleText,
            description: descriptionText,
            address: addressText,
            latitude: property.latitude,
            longitude: property.longitude,
            monthlyRent:   rent,
            bedrooms:      beds,
            squareFootage: sqft,
            bathrooms:     baths,
            contactInfo:   contactInfoText,
            availableFrom: availableFrom,
            isListed: property.isListed,
            createdAt: property.createdAt
        )

        service.updateProperty(updated) { error in
            DispatchQueue.main.async {
                if error == nil {
                    isEditing = false
                    showUpdateSuccess = true
                }
            }
        }
    }

    private func deleteProperty() {
        service.deleteProperty(property) { _ in
            presentation.wrappedValue.dismiss()
        }
    }
}
