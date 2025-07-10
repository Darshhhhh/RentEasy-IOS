//
//  RequestsListView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct RequestsListView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = RequestViewModel()

    var body: some View {
        Group {
            if vm.requests.isEmpty {
                // No‐requests placeholder
                VStack {
                    Spacer()
                    Text("No requests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(vm.requests) { req in
                        NavigationLink {
                            RequestDetailView(request: req)
                                .environmentObject(authVM)
                        } label: {
                            RequestRowView(request: req)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Requests")
        .onAppear {
            if let uid = authVM.user?.uid {
                vm.fetch(ownerId: uid)
            }
        }
    }
}

// RequestRowView
struct RequestRowView: View {
    let request: RequestModel
    @State private var propertyName: String = "Loading…"
    private let service = FirestoreService()

    private var statusIcon: String {
        switch request.status {
        case "pending":  return "hourglass"
        case "approved": return "checkmark.circle.fill"
        case "denied":   return "xmark.circle.fill"
        default:         return "questionmark.circle"
        }
    }

    private var statusColor: Color {
        switch request.status {
        case "pending":  return .orange
        case "approved": return .green
        case "denied":   return .red
        default:         return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundColor(statusColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(propertyName)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Text(request.status.capitalized)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(statusColor)

                    Spacer()

                    Text(request.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .onAppear(perform: loadPropertyName)
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
}

