//
//  ShortlistViewModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

class ShortlistViewModel: ObservableObject {
    @Published var items: [ShortlistModel] = []
    private let service = FirestoreService()

    func fetch(tenantId: String) {
        service.fetchShortlist(tenantId: tenantId) { result in
            DispatchQueue.main.async {
                if case .success(let arr) = result { self.items = arr }
            }
        }
    }

    func add(_ item: ShortlistModel) {
        service.addToShortlist(item) { _ in self.fetch(tenantId: item.tenantId) }
    }

    func remove(_ item: ShortlistModel) {
        service.removeFromShortlist(item) { _ in self.fetch(tenantId: item.tenantId) }
    }
}
