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
            db.collection(Constants.usersCollection)
              .document(uid)
              .getDocument { snapshot, error in
                if let error = error {
                  return completion(.failure(error))
                }
                guard let data = snapshot?.data() else {
                  return completion(.failure(FirestoreError.parsingError))
                }

                // Required
                guard
                  let email = data["email"] as? String,
                  let name  = data["name"]  as? String,
                  let role  = data["role"]  as? String
                else {
                  return completion(.failure(FirestoreError.parsingError))
                }

                // Optional with defaults
                let contact    = data["contact"]    as? String ?? ""
                let cardNumber = data["cardNumber"] as? String
                               ?? data["paymentInfo"] as? String
                               ?? ""

                let user = UserModel(
                    uid: uid,
                    email: email,
                    name: name,
                    role: role,
                    contact: contact,
                    cardNumber: cardNumber
                )
                completion(.success(user))
            }
        }
    // MARK: — Update profile
    func updateUserProfile(_ user: UserModel, completion: @escaping (Error?) -> Void) {
            let data: [String:Any] = [
                "name": user.name,
                "contact": user.contact,
                "cardNumber": user.cardNumber
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
                        let ownerId      = d["ownerId"]       as? String,
                        let title        = d["title"]         as? String,
                        let desc         = d["description"]   as? String,
                        let address      = d["address"]       as? String,
                        let isListed     = d["isListed"]      as? Bool,
                        let tsCreated    = d["createdAt"]     as? Timestamp,
                        let monthlyRent  = d["monthlyRent"]   as? Double,
                        let bedrooms     = d["bedrooms"]      as? Int,
                        let squareFoot   = d["squareFootage"] as? Double,
                        let bathrooms    = d["bathrooms"]     as? Double,
                        let contactInfo  = d["contactInfo"]   as? String,
                        let tsAvailable  = d["availableFrom"] as? Timestamp
                    else {
                        return nil
                    }

                    return PropertyModel(
                        id: doc.documentID,
                        ownerId: ownerId,
                        title: title,
                        description: desc,
                        address: address,
                        latitude: d["latitude"]   as? Double,
                        longitude: d["longitude"] as? Double,
                        monthlyRent:   monthlyRent,
                        bedrooms:      bedrooms,
                        squareFootage: squareFoot,
                        bathrooms:     bathrooms,
                        contactInfo:   contactInfo,
                        availableFrom: tsAvailable.dateValue(),
                        isListed: isListed,
                        createdAt: tsCreated.dateValue()
                    )
                } ?? []
                completion(.success(models))
            }
        }
    
    // MARK: — Fetch single property
    func fetchProperty(id: String, completion: @escaping (Result<PropertyModel, Error>) -> Void) {
            db.collection(Constants.propertiesCollection)
              .document(id)
              .getDocument { snap, err in
                if let err = err {
                    return completion(.failure(err))
                }
                guard
                  let d = snap?.data(),
                  let ownerId      = d["ownerId"]       as? String,
                  let title        = d["title"]         as? String,
                  let desc         = d["description"]   as? String,
                  let address      = d["address"]       as? String,
                  let isListed     = d["isListed"]      as? Bool,
                  let tsCreated    = d["createdAt"]     as? Timestamp,
                  let monthlyRent  = d["monthlyRent"]   as? Double,
                  let bedrooms     = d["bedrooms"]      as? Int,
                  let squareFoot   = d["squareFootage"] as? Double,
                  let bathrooms    = d["bathrooms"]     as? Double,
                  let contactInfo  = d["contactInfo"]   as? String,
                  let tsAvailable  = d["availableFrom"] as? Timestamp
                else {
                  return completion(.failure(FirestoreError.parsingError))
                }

                let prop = PropertyModel(
                    id: id,
                    ownerId: ownerId,
                    title: title,
                    description: desc,
                    address: address,
                    latitude: d["latitude"]   as? Double,
                    longitude: d["longitude"] as? Double,
                    monthlyRent:   monthlyRent,
                    bedrooms:      bedrooms,
                    squareFootage: squareFoot,
                    bathrooms:     bathrooms,
                    contactInfo:   contactInfo,
                    availableFrom: tsAvailable.dateValue(),
                    isListed: isListed,
                    createdAt: tsCreated.dateValue()
                )
                completion(.success(prop))
            }
        }

    // MARK: — Add / Update / Delete property
        func addProperty(_ p: PropertyModel, completion: @escaping (Error?) -> Void) {
            let dict: [String:Any] = [
                "ownerId":       p.ownerId,
                "title":         p.title,
                "description":   p.description,
                "address":       p.address,
                "latitude":      p.latitude as Any,
                "longitude":     p.longitude as Any,
                "isListed":      p.isListed,
                "createdAt":     p.createdAt,
                "monthlyRent":   p.monthlyRent,
                "bedrooms":      p.bedrooms,
                "squareFootage": p.squareFootage,
                "bathrooms":     p.bathrooms,
                "contactInfo":   p.contactInfo,
                "availableFrom": p.availableFrom
            ]
            db.collection(Constants.propertiesCollection)
              .addDocument(data: dict, completion: completion)
        }

        func updateProperty(_ p: PropertyModel, completion: @escaping (Error?) -> Void) {
            let dict: [String:Any] = [
                "title":         p.title,
                "description":   p.description,
                "address":       p.address,
                "latitude":      p.latitude as Any,
                "longitude":     p.longitude as Any,
                "isListed":      p.isListed,
                "monthlyRent":   p.monthlyRent,
                "bedrooms":      p.bedrooms,
                "squareFootage": p.squareFootage,
                "bathrooms":     p.bathrooms,
                "contactInfo":   p.contactInfo,
                "availableFrom": p.availableFrom
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

    
    func deletePropertyAndRequests(
            propertyId: String,
            completion: @escaping (Error?) -> Void
        ) {
            let batch = db.batch()
            
            // 1) unlist the property
            let propRef = db
                .collection(Constants.propertiesCollection)
                .document(propertyId)
            batch.updateData(["isListed": false], forDocument: propRef)
            
            // 2) fetch all requests for that property
            db.collection(Constants.requestsCollection)
              .whereField("propertyId", isEqualTo: propertyId)
              .getDocuments { snap, err in
                if let err = err {
                  return completion(err)
                }
                // 3) delete each request doc
                snap?.documents.forEach { doc in
                  batch.deleteDocument(doc.reference)
                }
                // 4) commit the batch
                batch.commit(completion: completion)
            }
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
