//
//  RequestDetailView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-09.
//

import SwiftUI
import UIKit

struct RequestDetailView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.presentationMode) var presentation

    let request: RequestModel
    @State private var status: String
    @State private var propertyName: String = "Loading…"
    @State private var tenantEmail: String  = "Loading…"

    private let service = FirestoreService()

    private var formattedDate: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: request.createdAt)
    }

    init(request: RequestModel) {
        self.request = request
        _status = State(initialValue: request.status)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Property
                infoRow(
                    icon: "house.fill",
                    label: "Property",
                    value: propertyName
                )

                // Requested By
                infoRow(
                    icon: "person.crop.circle",
                    label: "Requested By",
                    value: tenantEmail
                )

                // Requested On
                infoRow(
                    icon: "calendar",
                    label: "Requested On",
                    value: formattedDate
                )

                // Status row with icon, label, and dropdown
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Status")
                        .font(.headline)
                    Spacer()
                    Picker("", selection: $status) {
                        Text("Pending").tag("pending")
                        Text("Approved").tag("approved")
                        Text("Denied").tag("denied")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.vertical, 6)

                // Update Status button
                Button(action: saveStatus) {
                    Label("Update Status", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                // Contact Tenant button
                Button(action: contactTenant) {
                    Label("Contact Tenant", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding()
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPropertyName()
            loadTenantEmail()
        }
    }

    // MARK: - Helpers

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.headline)
                Text(value)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private func loadPropertyName() {
        service.fetchProperty(id: request.propertyId) { result in
            DispatchQueue.main.async {
                if case .success(let prop) = result {
                    propertyName = prop.title
                } else {
                    propertyName = "Unknown Property"
                }
            }
        }
    }

    private func loadTenantEmail() {
        service.fetchUser(uid: request.tenantId) { result in
            DispatchQueue.main.async {
                if case .success(let user) = result {
                    tenantEmail = user.email
                } else {
                    tenantEmail = "Unknown User"
                }
            }
        }
    }

    private func saveStatus() {
        var updated = request
        updated.status = status
        service.updateRequest(updated) { _ in
            DispatchQueue.main.async {
                presentation.wrappedValue.dismiss()
            }
        }
    }

    private func contactTenant() {
        guard let url = URL(string: "mailto:\(tenantEmail)"),
              UIApplication.shared.canOpenURL(url)
        else { return }
        UIApplication.shared.open(url)
    }
}
