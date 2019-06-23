//
//  DetailViewController.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/21.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: - Subviews
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: InventoryDescriptionTextView!
    
    // MARK: - Variables
    var inventoryName: String!
    var inventoryImageURL: URL!
    var inventoryDescription: String!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupItemBar()
        setupView()
    }
    
    // MARK: - IBActions
    @IBAction func goBidPressed(_ sender: Any) {
        
    }
    
    // MARK: -
    func setupItemBar() {
        
        navigationItem.title = inventoryName
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 5/255, green: 61/255, blue: 0/255, alpha: 1)
        ], for: .normal)
        
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Montserrat-SemiBold", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 5/255, green: 61/255, blue: 0/255, alpha: 1)
            ], for: .selected)
    }
    
    // MARK: -
    func setupView() {
        imageView.sd_setImage(with: inventoryImageURL, completed: nil)
        descriptionTextView.text = inventoryDescription
    }
    
    
    
}
