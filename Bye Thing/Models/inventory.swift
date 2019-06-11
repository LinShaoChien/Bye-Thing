//
//  Inventory.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/9.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class Inventory {
    let id: String,imageID: String, image: UIImage, name: String, type: InventoryType, description: String, lastModifyTime: Date, biddingStatus: Int
    
    init(id: String, imageID: String, image: UIImage, name: String, type: InventoryType, description: String, lastModifyTime: Date, biddingStatus: Int) {
        self.id = id
        self.imageID = imageID
        self.image = image
        self.name = name
        self.type = type
        self.description = description
        self.lastModifyTime = lastModifyTime
        self.biddingStatus = biddingStatus
    }
}
