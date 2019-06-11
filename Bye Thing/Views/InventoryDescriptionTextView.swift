//
//  InventoryDescriptionTextView.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/3.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

@IBDesignable
class InventoryDescriptionTextView: UITextView {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = #colorLiteral(red: 0.1764705882, green: 0.5137254902, blue: 0.168627451, alpha: 1)
    }
}
