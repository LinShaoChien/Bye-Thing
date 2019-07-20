//
//  FirestoreServices.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/1.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirestoreServices {
    
    static let sharedInstance = FirestoreServices()
    private let db = Firestore.firestore()
    
    // MARK: - Create user
    
    func createUser(uid: String, email: String) {
        db.collection("users").document(uid).setData([
            "email": email
        ])
    }
    
    // MARK: - Create inventory
    
    func createInventory(inventory: Inventory, completion: @escaping (Error?) -> ()) {
        db.collection("inventories").document(inventory.id).setData([
            "id": inventory.id,
            "userid": inventory.userid,
            "imageid": inventory.imageid,
            "name": inventory.name,
            "type": inventory.type.name,
            "description": inventory.description,
            "lastModified": inventory.lastModified,
            "bidStatus": inventory.bidStatus,
            "bidWinner": inventory.bidWinner
        ]) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARL: - Delete inventory
    
    func deleteInventory(id: String, imageid: String, completion: @escaping (Error?) -> ()) {
        StorageServices.sharedInstance.delete(imageID: imageid) { (error) in
            if let error = error {
                completion(error)
            } else {
                self.db.collection("inventories").document(id).delete()
                completion(nil)
            }
        }
    }
    
    // MARK: - Update inventory
    
    func updateInventory(uid: String, id: String, imageID: String?, itemName: String, itemType: String, itemDescription: String, lastModifyTime: Date, completion: @escaping (Bool, Error?) -> ()) {
        
        if let imageID = imageID {
            db.collection("inventories").document(id).updateData([
                "imageid": imageID,
                "name": itemName,
                "type": itemType,
                "description": itemDescription,
                "lastModified": lastModifyTime,
            ]) { (error) in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        } else {
            db.collection("inventories").document(id).updateData([
                "name": itemName,
                "type": itemType,
                "description": itemDescription,
                "lastModified": lastModifyTime,
            ]) { (error) in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - Get inventories
    
    func getInventories(ofUser userid: String?, type: InventoryType?, name: String?, limit: Int, after lastDocument: DocumentSnapshot?, completion: @escaping ([Inventory]?, [DocumentSnapshot]?, Error?) -> ()) {
        
        let limit = limit
        var documents: [DocumentSnapshot] = []
        var inventories: [Inventory] = []
        
        // Create compound query
        
        var query = db.collection("inventories").order(by: "lastModified", descending: true).limit(to: limit)
        if let userid = userid {
            query = query.whereField("userid", isEqualTo: userid)
        }
        if let type = type {
            query = query.whereField("type", isEqualTo: type.name)
        }
        if let name = name {
            query = query.whereField("name", isEqualTo: name)
        }
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, nil, error)
            } else {

                if let snapshot = snapshot {
                    
                    guard snapshot.count != 0 else {
                        completion(inventories, documents, nil)
                        return
                    }
                    
                    for document in snapshot.documents {
                        
                        documents.append(document)
                        
                        let data = document.data()
                        let id = data["id"] as! String
                        let userid = data["userid"] as! String
                        let imageid = data["imageid"] as! String
                        let name = data["name"] as! String
                        let type = InventoryType(name: data["type"] as! String)
                        let description = data["description"] as! String
                        let lastModified = (data["lastModified"] as! Timestamp).dateValue()
                        let bidStatus = data["bidStatus"] as! Int
                        let bidWinner = data["bidWinner"] as! String
                        
                        StorageServices.sharedInstance.getDownloadURL(imageid: imageid, completion: { (url, error) in
                            if let error = error {
                                completion(nil, nil, error)
                            } else {
                                if let url = url {
                                    let inventory = Inventory(id: id, userid: userid, imageid: imageid, imageurl: url, name: name, type: type, description: description, lastModified: lastModified, bidStatus: bidStatus, bidWinner: bidWinner)
                                    inventories.append(inventory)
                                    if inventories.count == snapshot.documents.count {
                                        inventories.sort(by: {$0.lastModified > $1.lastModified})
                                        completion(inventories, documents, nil)
                                    }
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Create bid
    func createBid(inventoryid: String, email: String, price: Int, completion: @escaping (Error?) -> ()) {
        let date = Date()
        db.collection("bids").addDocument(data: [
            "inventoryid": inventoryid,
            "email": email,
            "price": price,
            "time": date
        ]) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: -
    func getBids(ofInventory inventoryid: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> ()) {
        
        var documents = [DocumentSnapshot]()
        print(inventoryid)
        let query = db.collection("bids").whereField("inventoryid", isEqualTo: inventoryid)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let snapshot = snapshot {
                    print(snapshot.documents.count)
                    for document in snapshot.documents {
                        print("append")
                        documents.append(document)
                        if documents.count == snapshot.documents.count {
                            completion(documents, nil)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: -
    func getUserEmail(with userid: String, completion: @escaping (Error?, String?) -> ()) {
        let document = db.collection("users").document(userid)
        document.getDocument { (snapshot, error) in
            if let error = error {
                completion(error, nil)
            } else {
                if let snapshot = snapshot {
                    if let data = snapshot.data() {
                        let userEmail = data["email"] as! String
                        completion(nil, userEmail)
                    }
                }
            }
        }
    }
}
