//
//  InventoryTableVIewCellImageView.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/10.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

@IBDesignable
class InventoryTableVIewCellImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        configureBorder()
        configureCornerRadius()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureBorder()
        configureCornerRadius()
    }
    
    func configureCornerRadius() {
        self.layer.cornerRadius = 5
    }
    
    func configureBorder() {
        self.layer.borderColor = #colorLiteral(red: 0, green: 0.2979793549, blue: 0, alpha: 1)
        self.layer.borderWidth = 1
    }
}
