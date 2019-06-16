//
//  DiscoverViewController.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/11.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    // MARK: - Subviews
    @IBOutlet weak var tableView: UITableView!
    var indicator: UIActivityIndicatorView!

    // MARK: - Variables
    var inventories: [Inventory] = []
    
    // MARK: - View Controller Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureActivityIndicator()
        getInventories()
    }
    
    // MARK: - Configure Acitivity Indicator
    func configureActivityIndicator() {
        
        // Configure indicator
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = UIColor.lightGray
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        
        // Configure indicator auto layout
        indicator.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint = indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let centerYConstraint = indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([
            centerXConstraint,
            centerYConstraint
        ])
    }
    
    // MARK: - Get Inventories
    func getInventories() {
        indicator.startAnimating()
        FirestoreServices.sharedInstance.getInventories(ofUser: nil, type: nil, name: nil, limit: 20) { (inventories, error) in
            if let error = error {
                let alert = UIAlertController.errorAlert(error: error)
                self.indicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
            } else {
                self.indicator.stopAnimating()
                if let inventories = inventories {
                    self.inventories = inventories
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inventories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inventoryCell", for: indexPath) as! InventoryTableViewCell
        cell.configureCell(inventories: inventories, indexPath: indexPath)
        return cell
    }
    
}
