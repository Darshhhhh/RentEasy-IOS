//
//  RequestViewModel.swift
//  G1_Rental
//
//  Created by Darsh on 2025-07-08.
//


import Foundation

class RequestViewModel: ObservableObject {
    @Published var requests: [RequestModel] = []
    private let service = FirestoreService()

    func fetch(ownerId: String) {
        service.fetchRequests(ownerId: ownerId) { result in
            DispatchQueue.main.async {
                if case .success(let arr) = result { self.requests = arr }
            }
        }
    }

    func send(_ req: RequestModel) {
        service.sendRequest(req) { _ in /* no-op */ }
    }

    func update(_ req: RequestModel) {
        service.updateRequest(req) { _ in self.fetch(ownerId: req.ownerId) }
    }
}
