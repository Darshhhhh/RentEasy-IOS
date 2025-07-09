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
    @State private var isEditing = false
    
    // Editable fields
    @State private var titleText: String
    @State private var descriptionText: String
    @State private var addressText: String
    
    // Alert & confirmation flags
    @State private var showDeleteConfirmation = false
    @State private var showUpdateSuccess      = false
    
    private let service = FirestoreService()
    
    init(property: PropertyModel) {
        self.property = property
        _titleText       = State(initialValue: property.title)
        _descriptionText = State(initialValue: property.description)
        _addressText     = State(initialValue: property.address)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Map preview
                if let lat = property.latitude,
                   let lon = property.longitude {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: lat,
                                                              longitude: lon))
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                // Data fields
                VStack(alignment: .leading, spacing: 20) {
                    fieldRow(icon: "house.fill", label: "Property Name", content: $titleText)
                    fieldRow(icon: "doc.text.fill", label: "Property Description", content: $descriptionText)
                    fieldRow(icon: "mappin.and.ellipse", label: "Address", content: $addressText)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        if isEditing {
                            saveChanges()
                        } else {
                            isEditing = true
                        }
                    } label: {
                        Label(
                            isEditing ? "Save Changes" : "Edit Property",
                            systemImage: isEditing ? "square.and.arrow.down" : "square.and.pencil"
                        )
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
        // Confirmation for delete
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
        // Alert on successful update
        .alert("Property updated successfully", isPresented: $showUpdateSuccess) {
            Button("OK", role: .cancel) { }
        }
    }
    
    // MARK: - Field row helper
    
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
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Save & Delete
    
    private func saveChanges() {
        let updated = PropertyModel(
            id: property.id,
            ownerId: property.ownerId,
            title: titleText,
            description: descriptionText,
            address: addressText,
            latitude: property.latitude,
            longitude: property.longitude,
            isListed: property.isListed,
            createdAt: property.createdAt
        )
        service.updateProperty(updated) { error in
            DispatchQueue.main.async {
                if error == nil {
                    isEditing = false
                    showUpdateSuccess = true
                }
                // else: handle error if desired
            }
        }
    }
    
    private func deleteProperty() {
        service.deletePropertyAndRequests(propertyId: property.id) { err in
            DispatchQueue.main.async {
                if let err = err {
                    // handle error (e.g. show an alert)
                    print("Delete failed:", err)
                } else {
                    presentation.wrappedValue.dismiss()
                }
            }
        }
    }
}
