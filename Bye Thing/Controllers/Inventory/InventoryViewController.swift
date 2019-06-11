//
//  InventoryViewController.swift
//  Bye Thing
//
//  Created by 林劭謙 on 2019/6/2.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseAuth

class InventoryViewController: UIViewController {

    // Subviews
    @IBOutlet weak var inventoryTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    var indicator: UIActivityIndicatorView!
    
    // Variables
    var inventories: [Inventory]?
    
    // Segues
    enum Segue {
        static let AddNewInventory = "toAddNewInventory"
    }
    
    // View Controller Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addActivityIndicator()
        
        self.inventoryTableView.delegate = self
        self.inventoryTableView.dataSource = self
        
        getAllInventory()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updataInventory(_:)), name: NSNotification.Name("didAddNewInventory"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.AddNewInventory {
            
            let destination = segue.destination as! AddNewInventoryViewController
            
            if let indexPath = sender as? IndexPath {
                let inventory = inventories![indexPath.row]
                print(inventory.name)
                destination.isEditMode = true
                destination.currentInventory = inventory
            }
        }
    }
    
    // MARK: - Create and add activity indicator to view
    func addActivityIndicator() {
        
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
    
    func getAllInventory() {
        
        indicator.startAnimating()
        addButton.isEnabled = false
        
        let uid = Auth.auth().currentUser!.uid
        
        FirestoreServices.sharedInstance.getAllInventory(uid: uid) { (inventorylist, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.inventories = inventorylist!
                self.inventoryTableView.reloadData()
                self.indicator.stopAnimating()
                self.addButton.isEnabled = true
            }
        }
    }
    
    @objc func updataInventory(_ notification: Notification) {
        
        indicator.startAnimating()
        addButton.isEnabled = false
        
        let uid = Auth.auth().currentUser!.uid
        FirestoreServices.sharedInstance.getAllInventory(uid: uid) { (inventorylist, error) in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.inventories = inventorylist!
                self.inventoryTableView.reloadData()
                self.indicator.stopAnimating()
                self.addButton.isEnabled = true
            }
        }
    }

    @IBAction func plusPressed(_ sender: Any) {
        performSegue(withIdentifier: Segue.AddNewInventory, sender: nil)
    }
    
}

extension InventoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let inventories = inventories {
            return inventories.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "inventoryCell", for: indexPath) as! InventoryTableViewCell
        if let inventories = inventories {
            cell.configureCell(inventories: inventories, indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.performSegue(withIdentifier: Segue.AddNewInventory, sender: indexPath)
    }
    
}