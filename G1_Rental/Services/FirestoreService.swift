import Foundation
import FirebaseFirestore

/// Simple error for bad Firestore documents
enum FirestoreError: Error {
    case parsingError
}

class FirestoreService {
    private let db = Firestore.firestore()

    // MARK: — Fetch single user
    func fetchUser(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        db.collection(Constants.usersCollection).document(uid).getDocument { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard
                let data = snapshot?.data(),
                let email = data["email"]     as? String,
                let name  = data["name"]      as? String,
                let role  = data["role"]      as? String,
                let contact     = data["contact"]     as? String,
                let paymentInfo = data["paymentInfo"] as? String
            else {
                return completion(.failure(FirestoreError.parsingError))
            }
            let user = UserModel(
                uid: uid,
                email: email,
                name: name,
                role: role,
                contact: contact,
                paymentInfo: paymentInfo
            )
            completion(.success(user))
        }
    }

    // MARK: — Update profile
    func updateUserProfile(_ user: UserModel, completion: @escaping (Error?) -> Void) {
        let data: [String:Any] = [
            "name": user.name,
            "contact": user.contact,
            "paymentInfo": user.paymentInfo
        ]
        db.collection(Constants.usersCollection)
          .document(user.uid)
          .setData(data, merge: true, completion: completion)
    }

    // MARK: — Fetch all listed properties
    func fetchProperties(completion: @escaping (Result<[PropertyModel], Error>) -> Void) {
        db.collection(Constants.propertiesCollection)
          .whereField("isListed", isEqualTo: true)
          .addSnapshotListener { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            let models: [PropertyModel] = snapshot?.documents.compactMap { doc in
                let d = doc.data()
                guard
                    let ownerId  = d["ownerId"]   as? String,
                    let title    = d["title"]     as? String,
                    let desc     = d["description"]as? String,
                    let address  = d["address"]   as? String,
                    let isListed = d["isListed"]  as? Bool,
                    let ts       = d["createdAt"] as? Timestamp
                else { return nil }

                return PropertyModel(
                    id: doc.documentID,
                    ownerId: ownerId,
                    title: title,
                    description: desc,
                    address: address,
                    latitude: d["latitude"]   as? Double,
                    longitude: d["longitude"] as? Double,
                    isListed: isListed,
                    createdAt: ts.dateValue()
                )
            } ?? []
            completion(.success(models))
        }
    }

    // MARK: — Add / Update / Delete property
    func addProperty(_ p: PropertyModel, completion: @escaping (Error?) -> Void) {
        let dict: [String:Any] = [
            "ownerId": p.ownerId,
            "title": p.title,
            "description": p.description,
            "address": p.address,
            "latitude": p.latitude as Any,
            "longitude": p.longitude as Any,
            "isListed": p.isListed,
            "createdAt": p.createdAt
        ]
        db.collection(Constants.propertiesCollection)
          .addDocument(data: dict, completion: completion)
    }

    func updateProperty(_ p: PropertyModel, completion: @escaping (Error?) -> Void) {
        let dict: [String:Any] = [
            "title": p.title,
            "description": p.description,
            "address": p.address,
            "latitude": p.latitude as Any,
            "longitude": p.longitude as Any,
            "isListed": p.isListed
        ]
        db.collection(Constants.propertiesCollection)
          .document(p.id)
          .setData(dict, merge: true, completion: completion)
    }

    func deleteProperty(_ p: PropertyModel, completion: @escaping (Error?) -> Void) {
        db.collection(Constants.propertiesCollection)
          .document(p.id)
          .updateData(["isListed": false], completion: completion)
    }

    // MARK: — Requests
    func fetchRequests(ownerId: String,
                       completion: @escaping (Result<[RequestModel], Error>) -> Void) {
        db.collection(Constants.requestsCollection)
          .whereField("ownerId", isEqualTo: ownerId)
          .addSnapshotListener { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            var requests = [RequestModel]()
            snapshot?.documents.forEach { doc in
                let d = doc.data()
                guard
                  let propertyId = d["propertyId"] as? String,
                  let tenantId   = d["tenantId"]   as? String,
                  let status     = d["status"]     as? String,
                  let ts         = d["createdAt"]  as? Timestamp
                else { return }
                let req = RequestModel(
                    id: doc.documentID,
                    propertyId: propertyId,
                    ownerId: ownerId,
                    tenantId: tenantId,
                    status: status,
                    createdAt: ts.dateValue()
                )
                requests.append(req)
            }
            completion(.success(requests))
        }
    }


    func sendRequest(_ r: RequestModel, completion: @escaping (Error?) -> Void) {
        let dict: [String:Any] = [
            "propertyId": r.propertyId,
            "ownerId": r.ownerId,
            "tenantId": r.tenantId,
            "status": r.status,
            "createdAt": r.createdAt
        ]
        db.collection(Constants.requestsCollection)
          .addDocument(data: dict, completion: completion)
    }

    func updateRequest(_ r: RequestModel, completion: @escaping (Error?) -> Void) {
        let dict = ["status": r.status]
        db.collection(Constants.requestsCollection)
          .document(r.id)
          .setData(dict, merge: true, completion: completion)
    }

    // MARK: — Shortlist
    func fetchShortlist(tenantId: String,
                        completion: @escaping (Result<[ShortlistModel], Error>) -> Void) {
        db.collection(Constants.shortlistCollection)
          .whereField("tenantId", isEqualTo: tenantId)
          .addSnapshotListener { snapshot, error in
            if let error = error {
                return completion(.failure(error))
            }
            var items = [ShortlistModel]()
            snapshot?.documents.forEach { doc in
                let d = doc.data()
                guard
                  let propertyId = d["propertyId"] as? String,
                  let ts         = d["createdAt"]  as? Timestamp
                else { return }
                let item = ShortlistModel(
                    id: doc.documentID,
                    tenantId: tenantId,
                    propertyId: propertyId,
                    createdAt: ts.dateValue()
                )
                items.append(item)
            }
            completion(.success(items))
        }
    }


    func addToShortlist(_ s: ShortlistModel, completion: @escaping (Error?) -> Void) {
        let dict: [String:Any] = [
            "tenantId": s.tenantId,
            "propertyId": s.propertyId,
            "createdAt": s.createdAt
        ]
        db.collection(Constants.shortlistCollection)
          .addDocument(data: dict, completion: completion)
    }

    func removeFromShortlist(_ s: ShortlistModel, completion: @escaping (Error?) -> Void) {
        db.collection(Constants.shortlistCollection)
          .document(s.id)
          .delete(completion: completion)
    }
}
