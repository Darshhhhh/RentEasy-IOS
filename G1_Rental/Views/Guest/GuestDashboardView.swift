//
//  GuestDashboardView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct GuestDashboardView: View {
    @StateObject private var vm = PropertyViewModel()
    @State private var search = ""

    private var filtered: [PropertyModel] {
        vm.properties.filter {
            search.isEmpty ||
            $0.title.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List(filtered) { property in
            NavigationLink(property.title) {
                GuestPropertyDetailView(property: property)
            }
        }
        .searchable(text: $search)
        .navigationTitle("Browse Properties")
        .onAppear { vm.fetchAll() }
    }
}
