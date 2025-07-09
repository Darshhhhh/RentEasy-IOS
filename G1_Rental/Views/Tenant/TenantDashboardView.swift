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

    var filtered: [PropertyModel] {
        vm.properties.filter {
            search.isEmpty || $0.title.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationView {
            List(filtered) { prop in
                NavigationLink(prop.title) {
                    TenantPropertyDetailView(property: prop)
                }
            }
            .searchable(text: $search)
            .navigationTitle("Browse Properties")
            .onAppear { vm.fetchAll() }
        }
    }
}
