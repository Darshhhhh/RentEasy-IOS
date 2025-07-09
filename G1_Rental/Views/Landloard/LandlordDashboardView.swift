//
//  LandlordDashboardView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//

//
//  LandlordDashboardView.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-12.
//

import SwiftUI

struct LandlordDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = PropertyViewModel()
    @State private var showAdd = false
    @State private var searchText = ""

    // Filtered list based on search text
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
                PropertyDetailView(property: prop)
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
        .navigationTitle("My Properties")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAdd.toggle()
                } label: {
                    Label("Add Property", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .tint(.blue)
            }
        }
        .sheet(isPresented: $showAdd) {
            AddPropertyView()
                .environmentObject(authVM)
        }
        .onAppear {
            vm.fetchAll()
        }
    }
}


