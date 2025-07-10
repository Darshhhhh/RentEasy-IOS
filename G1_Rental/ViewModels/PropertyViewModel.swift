//
//  PropertyViewModel.swift
//  G1_Rental
//
//  Updated by Darsh on 2025-07-14.
//

import Foundation

class PropertyViewModel: ObservableObject {
    @Published var properties: [PropertyModel] = []
    private let service = FirestoreService()

    // Fetch all listed properties (for tenants & guests)
    func fetchAll() {
        service.fetchProperties { result in
            DispatchQueue.main.async {
                if case .success(let arr) = result {
                    self.properties = arr
                }
            }
        }
    }

    // Fetch *only* this landlord’s listings
    func fetchOwnerProperties(ownerId: String) {
        service.fetchProperties { result in
            DispatchQueue.main.async {
                if case .success(let allProps) = result {
                    self.properties = allProps.filter { $0.ownerId == ownerId }
                }
            }
        }
    }

    func add(_ prop: PropertyModel) {
        service.addProperty(prop) { _ in self.fetchAll() }
    }

    func update(_ prop: PropertyModel) {
        service.updateProperty(prop) { _ in self.fetchAll() }
    }

    func remove(_ prop: PropertyModel) {
        service.deleteProperty(prop) { _ in self.fetchAll() }
    }
}

