//
//  InventoryTableViewCell.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/9.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class InventoryTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDetail: InventoryTableViewCellLabelsView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var biddingStatus: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var item: Inventory!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureCell(inventories: [Inventory], indexPath: IndexPath) {
        
        if indexPath.row + 1 > inventories.count {
            indicator.startAnimating()
            itemName.text = ""
            biddingStatus.text = ""
            itemImage.image = nil
            return
        }
        
        // Configure labels
        itemName.text = inventories[indexPath.row].name
        let bidStatus = inventories[indexPath.row].bidStatus
        switch bidStatus {
        case 0:
            self.biddingStatus.text = "No one is bidding yet"
        case 1:
            self.biddingStatus.text = "1 person is bidding"
        default:
            self.biddingStatus.text = "\(bidStatus) people are bidding"
        }
        
        // Configure image
        itemImage.image = nil
        let size = itemImage.bounds.size
        let image = inventories[indexPath.row].image
        let renderer = UIGraphicsImageRenderer(size: size)
        let adjustedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        self.itemImage.image = adjustedImage
        
    }

}
