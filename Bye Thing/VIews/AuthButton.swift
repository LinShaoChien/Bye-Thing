//
//  AuthButton.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/5/28.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCornerRadius()
        setupShadow()
    }
    
    private func setupCornerRadius() {
        self.layer.cornerRadius = 5
    }
    
    private func setupShadow() {
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2
    }

}
