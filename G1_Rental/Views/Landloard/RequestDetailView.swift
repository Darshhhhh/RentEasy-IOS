//
//  RequestDetailView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct RequestDetailView: View {
    let request: RequestModel
    @State private var status: String
    private let service = FirestoreService()
    @EnvironmentObject var authVM: AuthViewModel

    init(request: RequestModel) {
        self.request = request
        _status = State(initialValue: request.status)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Request for \(request.propertyId)").font(.headline)
            Picker("Status", selection: $status) {
                Text("pending").tag("pending")
                Text("approved").tag("approved")
                Text("denied").tag("denied")
            }
            .pickerStyle(SegmentedPickerStyle())

            Button("Update") {
                var updated = request
                updated.status = status
                service.updateRequest(updated) { _ in }
            }
        }
        .padding()
        .navigationTitle("Request Detail")
    }
}
