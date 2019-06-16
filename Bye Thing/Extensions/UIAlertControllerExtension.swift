//
//  UIAlertControllerExtension.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/14.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func errorAlert(error: Error) -> UIAlertController {
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        return alert
        
    }
    
}
