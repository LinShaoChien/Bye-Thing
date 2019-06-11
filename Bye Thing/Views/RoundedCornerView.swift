//
//  RoundedCornerView.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/10.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornerView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureRoundedCorner()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureRoundedCorner()
    }

    func configureRoundedCorner() {
        self.layer.cornerRadius = 5
    }
    
}
