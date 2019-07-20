//
//  BidTableViewCell.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/7/13.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseFirestore

class BidTableViewCell: UITableViewCell {
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var bidDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(documents: [DocumentSnapshot], indexPath: IndexPath) {
        let document = documents[indexPath.row]
        if let data = document.data() {
            let email = data["email"] as! String
            let price = data["price"] as! Int
            let date = (data["time"] as! Timestamp).dateValue()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strDate = dateFormatter.string(from: date)
            let bidDetail = email + " bid at \(price)"
            self.bidDetail.text = bidDetail
            self.date.text = "\(strDate)"
        }
    }
}
