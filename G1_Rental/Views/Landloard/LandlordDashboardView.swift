//
//  LandlordDashboardView.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import SwiftUI

struct LandlordDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = PropertyViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationView {
            List(vm.properties) { prop in
                NavigationLink(prop.title) {
                    PropertyDetailView(property: prop)
                }
            }
            .navigationTitle("My Properties")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAdd.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddPropertyView()
            }
            .onAppear { vm.fetchAll() }
        }
    }
}
