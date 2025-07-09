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
        List(vm.requests) { req in
            NavigationLink(req.status.capitalized) {
                RequestDetailView(request: req)
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
