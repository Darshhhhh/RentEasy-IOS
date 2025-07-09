//
//  TenantDashboardView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct TenantDashboardView: View {
    @StateObject private var vm = PropertyViewModel()
    @State private var search = ""
    @EnvironmentObject var authVM: AuthViewModel

    // Filtered properties by search
    private var filtered: [PropertyModel] {
        vm.properties.filter {
            search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { prop in
                NavigationLink {
                    TenantPropertyDetailView(property: prop)
                        .environmentObject(authVM)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundColor(.green)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(prop.title)
                                .font(.headline)
                                .foregroundColor(.primary)

                            HStack(spacing: 16) {
                                Text(String(format: "$%.0f/mo", prop.monthlyRent))
                                    .font(.subheadline)
                                Text("\(prop.bedrooms) bd")
                                    .font(.subheadline)
                            }

                            Text(prop.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always))
        .navigationTitle("Browse Properties")
        .onAppear { vm.fetchAll() }
    }
}
