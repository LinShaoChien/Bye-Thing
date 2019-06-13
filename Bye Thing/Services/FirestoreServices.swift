//
//  FirestoreServices.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/1.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreServices {
    
    static let sharedInstance = FirestoreServices()
    
    private let db = Firestore.firestore()
    private var uid = Auth.auth().currentUser!.uid
    
    // MARK: - Create user
    
    func createUser(uid: String, email: String) {
        db.collection("users").document(uid).setData([
            "email": email
        ])
    }
    
    // MARK: - Create inventory
    
    func createInventory(uid: String, imageID: String, itemName: String, itemType: String, itemDescription: String, lastModifyTime: Date, completion: @escaping (Bool, Error?) -> ()) {
        print(uid)
        db.collection("users").document(uid).collection("inventories").addDocument(data: [
            "imageID": imageID,
            "itemName": itemName,
            "itemType": itemType,
            "itemDescription": itemDescription,
            "lastModifyTime": lastModifyTime,
            "biddingStatus": 0
        ]) { (error) in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Update inventory
    
    func updateInventory(uid: String, id: String, imageID: String?, itemName: String, itemType: String, itemDescription: String, lastModifyTime: Date, completion: @escaping (Bool, Error?) -> ()) {
        
        if let imageID = imageID {
            db.collection("users").document(uid).collection("inventories").document(id).updateData([
                "imageID": imageID,
                "itemName": itemName,
                "itemType": itemType,
                "itemDescription": itemDescription,
                "lastModifyTime": lastModifyTime,
            ]) { (error) in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        } else {
            db.collection("users").document(uid).collection("inventories").document(id).updateData([
                "itemName": itemName,
                "itemType": itemType,
                "itemDescription": itemDescription,
                "lastModifyTime": lastModifyTime,
            ]) { (error) in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    }
    
    // MARK: - Get all inventory
    
    func getAllInventory(uid: String, completion: @escaping ([Inventory]?, Error?) -> ()) {
        
        db.collection("users").document(uid).collection("inventories").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                if let snapshot = snapshot {
                    
                    var inventories: [Inventory] = []
                    
                    guard snapshot.documents.count != 0 else {
                        completion(inventories, nil)
                        return
                    }
                    
                    for document in snapshot.documents {
                        
                        let data = document.data()
                        let id = document.documentID
                        let name = data["itemName"] as! String
                        let type = InventoryType(name: data["itemType"] as! String)
                        let description = data["itemDescription"] as! String
                        let date = (data["lastModifyTime"] as! Timestamp).dateValue()
                        let imageID = data["imageID"] as! String
                        let biddingStatus = data["biddingStatus"] as! Int
                        
                        StorageServices.sharedInstance.download(imageID: imageID, completion: { (image, error) in
                            if let error = error {
                                // Handle error
                                print(error.localizedDescription)
                            } else {
                                let inventory = Inventory(id: id, imageID: imageID, image: image!, name: name, type: type, description: description, lastModifyTime: date, biddingStatus: biddingStatus)
                                inventories.append(inventory)
                            }
                            
                            if inventories.count == snapshot.documents.count {
                                let sorted = inventories.sorted(by: { (inventory1, inventory2) -> Bool in
                                    return inventory1.lastModifyTime > inventory2.lastModifyTime
                                })
                                completion(sorted, nil)
                            }
                        })
                    }
                }
            }
        }
    }
    
    // Create Inventory
    func create(inventory: Inventory, completion: @escaping (Error?) -> ()) {
        db.collection("inventories").addDocument(data: [
            "userID": inventory.,
            "lastModifyDate": String,
        ]) { (error) in
            if let error = error {
                
            }
        }
    }
    
    
}
