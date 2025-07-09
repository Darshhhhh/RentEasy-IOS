//
//  GuestDashboardView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct GuestDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = PropertyViewModel()
    @State private var searchText = ""

    private var filteredProperties: [PropertyModel] {
        guard !searchText.isEmpty else { return vm.properties }
        return vm.properties.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List(filteredProperties) { prop in
            NavigationLink {
                GuestPropertyDetailView(property: prop)
                    .environmentObject(authVM)
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.title2)
                        .foregroundColor(.green)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(prop.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(prop.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Browse as Guest")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .onAppear { vm.fetchAll() }
    }
}
