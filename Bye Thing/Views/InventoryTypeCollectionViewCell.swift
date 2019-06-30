//
//  InventoryTypeCollectionViewCell.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/3.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class InventoryTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var inventoryTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configureCell(typeName: String) {
        self.inventoryTypeLabel.text = typeName
        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.5137254902, blue: 0.168627451, alpha: 1)
        setStyle()
    }
    
    func setStyle() {
        if isSelected {
            self.backgroundColor = #colorLiteral(red: 0.1764705882, green: 0.5137254902, blue: 0.168627451, alpha: 1)
            self.inventoryTypeLabel.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor.white
            self.inventoryTypeLabel.textColor = #colorLiteral(red: 0.1764705882, green: 0.5137254902, blue: 0.168627451, alpha: 1)
        }
    }
}
