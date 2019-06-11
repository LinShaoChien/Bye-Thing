//
//  FirebaseStorageServices.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/7.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageServices {
    
    static let sharedInstance = StorageServices()
    
    private let storage = Storage.storage()
    
    func upload(data: Data, withName name: String, inChild child: String, completion: @escaping (Bool, Error?) -> ()) {
        let storageRef = storage.reference().child(child + "/" + name)
        storageRef.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func download(imageID: String, completion: @escaping (UIImage?, Error?) -> ()) {
        let imageRef = storage.reference().child("images/" + imageID + ".jpeg")
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if let error = error {
                completion(nil, error)
            } else {
                let image = UIImage(data: data!)
                completion(image, nil)
            }
        }
    }
    
    func delete(imageID: String, completion: @escaping (Error?) -> ()) {
        let imageRef = storage.reference().child("images/" + imageID + ".jpeg")
        imageRef.delete { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
}
