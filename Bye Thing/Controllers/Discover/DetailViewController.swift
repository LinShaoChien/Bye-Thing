//
//  DetailViewController.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/21.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DetailViewController: UIViewController {

    // MARK: - Subviews
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: InventoryDescriptionTextView!
    
    // MARK: - Variables
    var inventoryName: String!
    var inventoryImageURL: URL!
    var inventoryDescription: String!
    var inventoryID: String!
    var inventoryBidHistory: [DocumentSnapshot]!
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupItemBar()
        setupView()
        getBidHistory()
        
    }
    
    // MARK: - IBActions
    @IBAction func goBidPressed(_ sender: Any) {
        createBid()
    }
    
    // MARK: -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHistory" {
            let destination = segue.destination as! HistoryViewController
            destination.documents = inventoryBidHistory
        }
    }
    
    // MARK: -
    func getBidHistory() {
        FirestoreServices.sharedInstance.getBids(ofInventory: inventoryID) { (documents, error) in
            if let error = error {
                let alert = UIAlertController.errorAlert(error: error)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.inventoryBidHistory = documents
            }
        }
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
    
    // MARL: -
    func createBid() {
        if let email = Auth.auth().currentUser?.email {
            // TODO: - Bid price
            let price = 100
            
            FirestoreServices.sharedInstance.createBid(inventoryid: inventoryID, email: email, price: price) { (error) in
                if let error = error {
                    let alert = UIAlertController.errorAlert(error: error)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
