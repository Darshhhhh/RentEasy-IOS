//
//  ShortlistView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct ShortlistView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = ShortlistViewModel()

    var body: some View {
        List(vm.items) { item in
            Text(item.propertyId) // you could fetch property details if you like
                .swipeActions {
                    Button(role: .destructive) {
                        vm.remove(item)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
        }
        .navigationTitle("Shortlist")
        .onAppear {
            if let uid = authVM.user?.uid {
                vm.fetch(tenantId: uid)
            }
        }
    }
}
