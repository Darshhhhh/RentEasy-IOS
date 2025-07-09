//
//  PropertyViewModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

class PropertyViewModel: ObservableObject {
    @Published var properties: [PropertyModel] = []
    private let service = FirestoreService()

    func fetchAll() {
        service.fetchProperties { result in
            DispatchQueue.main.async {
                if case .success(let arr) = result { self.properties = arr }
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
