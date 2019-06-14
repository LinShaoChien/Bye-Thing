//
//  Inventory.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/9.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class Inventory {
    
    // MARK: - Properties
    var id: String
    var userid: String
    var imageid: String
    var image: UIImage
    var name: String
    var type: InventoryType
    var description: String
    var lastModified: Date
    var bidStatus: Int
    var bidWinner: String
    
    // MARK: - Init
    init(id: String, userid: String, imageid: String, image: UIImage, name: String, type: InventoryType, description: String, lastModified: Date, bidStatus: Int, bidWinner: String) {
        self.id = id
        self.userid = userid
        self.imageid = imageid
        self.image = image
        self.name = name
        self.type = type
        self.description = description
        self.lastModified = lastModified
        self.bidStatus = bidStatus
        self.bidWinner = bidWinner
    }
}
