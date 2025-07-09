//
//  ShortlistViewModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

class ShortlistViewModel: ObservableObject {
    @Published var properties: [PropertyModel] = []
    private let service = FirestoreService()
    
    func fetch(tenantId: String) {
        self.service.fetchShortlist(tenantId: tenantId) { result in
            switch result {
            case .success(let items):
                // 1) Sort shortlist entries by createdAt descending
                let sorted = items.sorted { $0.createdAt > $1.createdAt }

                // 2) Fetch properties in that order
                let group = DispatchGroup()
                var fetched: [PropertyModel] = []

                for entry in sorted {
                    group.enter()
                    self.service.fetchProperty(id: entry.propertyId) { res in
                        if case .success(let prop) = res {
                            fetched.append(prop)
                        }
                        group.leave()
                    }
                }

                // 3) When all are fetched, publish in the exact sorted order
                group.notify(queue: .main) {
                    self.properties = fetched
                }

            case .failure(let error):
                print("Shortlist fetch failed:", error)
                DispatchQueue.main.async {
                    self.properties = []
                }
            }
        }
    }
}
