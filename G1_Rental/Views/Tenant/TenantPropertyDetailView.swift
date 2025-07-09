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
    @StateObject private var shortlistVM = ShortlistViewModel()
    @Environment(\.presentationMode) var presentation
    private let service = FirestoreService()

    var body: some View {
        VStack(spacing: 16) {
            Text(property.title).font(.largeTitle)
            Text(property.description)
            Text(property.address).foregroundColor(.secondary)
            if let lat = property.latitude, let lon = property.longitude {
                MapView(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    .frame(height: 200)
            }
            HStack(spacing: 20) {
                Button("Shortlist") {
                    guard let uid = authVM.user?.uid else { return }
                    let item = ShortlistModel(
                        id: UUID().uuidString,
                        tenantId: uid,
                        propertyId: property.id,
                        createdAt: Date()
                    )
                    shortlistVM.add(item)
                }
                Button("Request") {
                    guard let uid = authVM.user?.uid else { return }
                    let req = RequestModel(
                        id: UUID().uuidString,
                        propertyId: property.id,
                        ownerId: property.ownerId,
                        tenantId: uid,
                        status: "pending",
                        createdAt: Date()
                    )
                    service.sendRequest(req) { _ in
                        presentation.wrappedValue.dismiss()
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}
