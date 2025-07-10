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
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Map (flush‐edge)
                if let lat = property.latitude, let lon = property.longitude {
                    MapView(
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    )
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                
                // Property details
                VStack(alignment: .leading, spacing: 20) {
                    fieldRow(icon: "house.fill",             label: "Title",          value: property.title)
                    fieldRow(icon: "doc.text.fill",          label: "Description",    value: property.description)
                    fieldRow(icon: "mappin.and.ellipse",     label: "Address",        value: property.address)
                    fieldRow(icon: "dollarsign.circle.fill", label: "Monthly Rent",   value: String(format: "$%.0f", property.monthlyRent))
                    fieldRow(icon: "bed.double.fill",        label: "Bedrooms",       value: "\(property.bedrooms)")
                    fieldRow(icon: "ruler.fill",             label: "Square Footage", value: String(format: "%.0f sq ft", property.squareFootage))
                    fieldRow(icon: "bathtub.fill",           label: "Bathrooms",      value: String(format: "%.1f", property.bathrooms))
                    fieldRow(icon: "phone.fill",             label: "Contact Info",   value: property.contactInfo)
                    fieldRow(icon: "calendar",               label: "Available From", value:
                                DateFormatter.localizedString(
                                    from: property.availableFrom,
                                    dateStyle: .medium,
                                    timeStyle: .none
                                )
                    )
                }
                .padding(.horizontal)
                
                // Prompt to log in for actions
                Button {
                    // pop back to login
                    presentation.wrappedValue.dismiss()
                    authVM.user = nil
                } label: {
                    Label("Log in to make inquiries", systemImage: "person.crop.circle.badge.questionmark")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fieldRow(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).font(.headline)
            }
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

