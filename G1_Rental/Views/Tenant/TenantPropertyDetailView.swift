//
//  TenantPropertyDetailView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI
import MapKit

struct TenantPropertyDetailView: View {
    let property: PropertyModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentation

    @State private var shortlistItems: [ShortlistModel] = []
    @State private var isShortlisted = false
    @State private var showRemoveConfirmation = false
    @State private var showShortlistAlert     = false
    @State private var shortlistMessage       = ""
    @State private var showRequestAlert       = false
    @State private var requestSent            = false

    private let service = FirestoreService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Map (flush left)
                if let lat = property.latitude, let lon = property.longitude {
                    MapView(
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    )
                    .frame(height: 200)
                    .cornerRadius(12)
                }

                // Property details (flush left)
                VStack(alignment: .leading, spacing: 20) {
                    fieldRow(icon: "house.fill",              label: "Title",            value: property.title)
                    fieldRow(icon: "doc.text.fill",           label: "Description",      value: property.description)
                    fieldRow(icon: "mappin.and.ellipse",      label: "Address",          value: property.address)
                    fieldRow(icon: "dollarsign.circle.fill",  label: "Monthly Rent",     value: String(format: "$%.0f", property.monthlyRent))
                    fieldRow(icon: "bed.double.fill",         label: "Bedrooms",         value: "\(property.bedrooms)")
                    fieldRow(icon: "ruler.fill",              label: "Square Footage",   value: String(format: "%.0f sq ft", property.squareFootage))
                    fieldRow(icon: "bathtub.fill",            label: "Bathrooms",        value: String(format: "%.1f", property.bathrooms))
                    fieldRow(icon: "phone.fill",              label: "Contact Info",     value: property.contactInfo)
                    fieldRow(icon: "calendar",                label: "Available From",   value: DateFormatter.localizedString(from: property.availableFrom, dateStyle: .medium, timeStyle: .none))
                }

                // Actions (tenant only; guest sees disabled buttons)
                VStack(spacing: 16) {
                    // Shortlist toggle
                    Button {
                        if isShortlisted {
                            showRemoveConfirmation = true
                        } else {
                            addToShortlist()
                        }
                    } label: {
                        Label(
                            isShortlisted ? "Remove from Shortlist" : "Add to Shortlist",
                            systemImage: isShortlisted ? "star.slash.fill" : "star.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isShortlisted ? .red : .blue)
                    .alert(shortlistMessage, isPresented: $showShortlistAlert) {
                        Button("OK", role: .cancel) {}
                    }
                    .confirmationDialog(
                        "Remove this property from your shortlist?",
                        isPresented: $showRemoveConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Remove", role: .destructive) { removeFromShortlist() }
                        Button("Cancel", role: .cancel) {}
                    }
                    .disabled(authVM.user?.role != "tenant")  // guest/landlord can't shortlist

                    // Request button
                    Button {
                        sendRequest()
                    } label: {
                        Label(
                            requestSent ? "Request Sent" : "Request Property",
                            systemImage: requestSent ? "checkmark.circle.fill" : "envelope.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(requestSent ? .gray : .green)
                    .disabled(requestSent || authVM.user?.role != "tenant")
                    .alert("Inquiry sent", isPresented: $showRequestAlert) {
                        Button("OK", role: .cancel) {}
                    }
                }
            }
            .padding(.top) // breathing room at top
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadShortlist)
    }

    private func fieldRow(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).font(.headline)
            }
            Text(value).font(.body).foregroundColor(.secondary)
        }
    }

    private func loadShortlist() {
        guard let uid = authVM.user?.uid else { return }
        service.fetchShortlist(tenantId: uid) { result in
            DispatchQueue.main.async {
                if case .success(let items) = result {
                    self.isShortlisted = items.contains { $0.propertyId == property.id }
                }
            }
        }
    }

    private func addToShortlist() {
        guard let uid = authVM.user?.uid else { return }
        let item = ShortlistModel(id: UUID().uuidString,
                                  tenantId: uid,
                                  propertyId: property.id,
                                  createdAt: Date())
        service.addToShortlist(item) { err in
            DispatchQueue.main.async {
                guard err == nil else { return }
                self.isShortlisted = true
                self.shortlistMessage = "Added to shortlist"
                self.showShortlistAlert = true
            }
        }
    }

    private func removeFromShortlist() {
        service.fetchShortlist(tenantId: authVM.user!.uid) { result in
            if case .success(let items) = result,
               let entry = items.first(where: { $0.propertyId == property.id }) {
                service.removeFromShortlist(entry) { err in
                    DispatchQueue.main.async {
                        guard err == nil else { return }
                        self.isShortlisted = false
                        self.shortlistMessage = "Removed from shortlist"
                        self.showShortlistAlert = true
                    }
                }
            }
        }
    }

    private func sendRequest() {
        guard let uid = authVM.user?.uid else { return }
        let req = RequestModel(id: UUID().uuidString,
                               propertyId: property.id,
                               ownerId: property.ownerId,
                               tenantId: uid,
                               status: "pending",
                               createdAt: Date())
        service.sendRequest(req) { _ in
            DispatchQueue.main.async {
                self.requestSent = true
                self.showRequestAlert = true
            }
        }
    }
}
