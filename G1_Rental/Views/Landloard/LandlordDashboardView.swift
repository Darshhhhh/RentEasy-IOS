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
        List(vm.properties) { prop in
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
