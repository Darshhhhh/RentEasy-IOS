//
//  ShortlistView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//

import SwiftUI

import SwiftUI

struct ShortlistView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ShortlistViewModel()

    var body: some View {
        List {
            ForEach(vm.properties) { prop in
                NavigationLink {
                    TenantPropertyDetailView(property: prop)
                        .environmentObject(authVM)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prop.title)
                                .font(.headline)
                            Text(String(format: "$%.0f/mo · %d bd", prop.monthlyRent, prop.bedrooms))
                                .font(.subheadline)
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
        .navigationTitle("Shortlist")
        .onAppear {
            if let uid = authVM.user?.uid {
                vm.fetch(tenantId: uid)
            }
        }
    }
}
