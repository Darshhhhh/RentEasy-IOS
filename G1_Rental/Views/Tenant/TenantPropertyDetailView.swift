//
//  TenantPropertyDetailView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-13.
//

import SwiftUI
import MapKit
import UIKit

struct TenantPropertyDetailView: View {
    let property: PropertyModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentation

    // Shortlist state
    @State private var isShortlisted             = false
    @State private var showRemoveShortlistCD     = false
    @State private var showShortlistAlert        = false
    @State private var shortlistMessage          = ""

    // Request state
    @State private var currentRequest: RequestModel?
    @State private var requestSent               = false
    @State private var showWithdrawConfirmation  = false
    @State private var showRequestAlert          = false

    // Share state
    @State private var showShareSheet            = false

    private let service = FirestoreService()

    // MARK: — Share Content
    private var shareText: String {
        """
        G1 RentalApp Listing:

        Title: \(property.title)
        Description: \(property.description)
        Address: \(property.address)
        Monthly Rent: $\(Int(property.monthlyRent))
        Bedrooms: \(property.bedrooms)
        Bathrooms: \(String(format: "%.1f", property.bathrooms))
        Available From: \(DateFormatter.localizedString(from: property.availableFrom, dateStyle: .medium, timeStyle: .none))

        Contact: \(property.contactInfo)
        """
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Map 
                if let lat = property.latitude, let lon = property.longitude {
                    MapView(
                        coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    )
                    .frame(height: 200)
                    .cornerRadius(12)
                }

                // Property fields
                VStack(alignment: .leading, spacing: 20) {
                    fieldRow(icon: "house.fill",             label: "Title",          value: property.title)
                    fieldRow(icon: "doc.text.fill",          label: "Description",    value: property.description)
                    fieldRow(icon: "mappin.and.ellipse",     label: "Address",        value: property.address)
                    fieldRow(icon: "dollarsign.circle.fill", label: "Monthly Rent",   value: String(format: "$%.0f", property.monthlyRent))
                    fieldRow(icon: "bed.double.fill",        label: "Bedrooms",       value: "\(property.bedrooms)")
                    fieldRow(icon: "bathtub.fill",           label: "Bathrooms",      value: String(format: "%.1f", property.bathrooms))
                    fieldRow(icon: "calendar",               label: "Available From", value:
                        DateFormatter.localizedString(
                            from: property.availableFrom,
                            dateStyle: .medium,
                            timeStyle: .none
                        )
                    )
                    fieldRow(icon: "phone.fill",             label: "Contact Info",   value: property.contactInfo)
                }
                .padding(.horizontal)

                // Actions
                VStack(spacing: 16) {
                    // Shortlist toggle
                    Button {
                        if isShortlisted {
                            showRemoveShortlistCD = true
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
                    .confirmationDialog(
                        "Remove this property from your shortlist?",
                        isPresented: $showRemoveShortlistCD,
                        titleVisibility: .visible
                    ) {
                        Button("Remove", role: .destructive) {
                            removeFromShortlist()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    .alert(shortlistMessage, isPresented: $showShortlistAlert) {
                        Button("OK", role: .cancel) {}
                    }
                    .disabled(authVM.user?.role != "tenant")

                    // Request / Withdraw toggle
                    Button {
                        if requestSent {
                            showWithdrawConfirmation = true
                        } else {
                            sendRequest()
                        }
                    } label: {
                        Label(
                            requestSent ? "Withdraw Request" : "Request Property",
                            systemImage: requestSent ? "arrow.uturn.backward.circle.fill" : "envelope.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(requestSent ? .red : .green)
                    .disabled(authVM.user?.role != "tenant")
                    .confirmationDialog(
                        "Are you sure you want to withdraw your inquiry?",
                        isPresented: $showWithdrawConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Withdraw", role: .destructive) {
                            withdrawRequest()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                    .alert("Request \(requestSent ? "withdrawn" : "sent")", isPresented: $showRequestAlert) {
                        Button("OK", role: .cancel) {}
                    }

                    // Share button
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .sheet(isPresented: $showShareSheet) {
                        ActivityView(activityItems: [shareText])
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadInitialState)
    }

    // MARK: — Helpers

    private func fieldRow(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label).font(.headline)
            }
            Text(value).font(.body).foregroundColor(.secondary)
        }
    }

    private func loadInitialState() {
        guard let uid = authVM.user?.uid else { return }
        // Load shortlist state
        service.fetchShortlist(tenantId: uid) { result in
            DispatchQueue.main.async {
                if case .success(let items) = result {
                    isShortlisted = items.contains { $0.propertyId == property.id }
                }
            }
        }
        // Load existing request state
        service.fetchTenantRequest(tenantId: uid, propertyId: property.id) { result in
            DispatchQueue.main.async {
                if case .success(let req) = result, let req = req {
                    currentRequest = req
                    requestSent    = true
                } else {
                    currentRequest = nil
                    requestSent    = false
                }
            }
        }
    }

    private func addToShortlist() {
        guard let uid = authVM.user?.uid else { return }
        let item = ShortlistModel(
            id: UUID().uuidString,
            tenantId: uid,
            propertyId: property.id,
            createdAt: Date()
        )
        service.addToShortlist(item) { err in
            DispatchQueue.main.async {
                guard err == nil else { return }
                isShortlisted    = true
                shortlistMessage = "Added to shortlist"
                showShortlistAlert = true
            }
        }
    }

    private func removeFromShortlist() {
        guard let uid = authVM.user?.uid else { return }
        service.fetchShortlist(tenantId: uid) { result in
            if case .success(let items) = result,
               let entry = items.first(where: { $0.propertyId == property.id }) {
                service.removeFromShortlist(entry) { err in
                    DispatchQueue.main.async {
                        guard err == nil else { return }
                        isShortlisted    = false
                        shortlistMessage = "Removed from shortlist"
                        showShortlistAlert = true
                    }
                }
            }
        }
    }

    private func sendRequest() {
        guard let uid = authVM.user?.uid else { return }
        let req = RequestModel(
            id: UUID().uuidString,
            propertyId: property.id,
            ownerId: property.ownerId,
            tenantId: uid,
            status: "pending",
            createdAt: Date()
        )
        service.sendRequest(req) { err in
            DispatchQueue.main.async {
                guard err == nil else { return }
                currentRequest = req
                requestSent    = true
                showRequestAlert = true
            }
        }
    }

    private func withdrawRequest() {
        guard let req = currentRequest else { return }
        service.deleteRequest(requestId: req.id) { err in
            DispatchQueue.main.async {
                guard err == nil else { return }
                currentRequest = nil
                requestSent    = false
                showRequestAlert = true
            }
        }
    }
}

// UIKit share sheet wrapper
fileprivate struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems,
                                 applicationActivities: nil)
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
