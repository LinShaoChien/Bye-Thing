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
    @IBOutlet weak var emptyInventoryImageView: UIImageView!
    @IBOutlet weak var promptLabel: UILabel!
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
        self.inventoryTableView.prefetchDataSource = self
        
        getAllInventory()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updataInventory(_:)), name: NSNotification.Name("didAddNewInventory"), object: nil)
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 5/255, green: 61/255, blue: 0/255, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 18)!
        ]
        
        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0.2979793549, blue: 0, alpha: 1)
        
        
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
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let uid = Auth.auth().currentUser!.uid
        
        FirestoreServices.sharedInstance.getInventories(ofUser: uid, type: nil, name: nil, limit: 50, after: nil) { (inventories, documents,  error) in
            
            if let error = error {
                print(error.localizedDescription)
                let alert = UIAlertController.errorAlert(error: error)
                self.present(alert, animated: true, completion: nil)
                self.indicator.stopAnimating()
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                if let inventories = inventories {
                    print(inventories.count)
                    self.inventories = inventories
                    self.inventoryTableView.reloadData()
                    self.indicator.stopAnimating()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    if inventories.count == 0 {
                        self.emptyInventoryImageView.isHidden = false
                        self.promptLabel.isHidden = false
                        // self.inventoryTableView.isHidden = true
                    }
                }
            }
        }

    }
    
    @objc func updataInventory(_ notification: Notification) {
        
        indicator.startAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let uid = Auth.auth().currentUser!.uid
        FirestoreServices.sharedInstance.getInventories(ofUser: uid, type: nil, name: nil, limit: 50, after: nil) { (inventories, documents, error) in
            if let error = error {
                let alert = UIAlertController.errorAlert(error: error)
                self.present(alert, animated: true, completion: nil)
            } else {
                if let inventories = inventories {
                    self.inventories = inventories
                    self.inventoryTableView.reloadData()
                    self.indicator.stopAnimating()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    if inventories.count == 0 {
                        print("No inventories!!!!!")
                        self.emptyInventoryImageView.isHidden = false
                        self.promptLabel.isHidden = false
                        self.inventoryTableView.isHidden = true
                    }
                }
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
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: Segue.AddNewInventory, sender: indexPath)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            if let inventories = self.inventories {
                let id = inventories[indexPath.row].id
                let imageid = inventories[indexPath.row].imageid
                FirestoreServices.sharedInstance.deleteInventory(id: id, imageid: imageid, completion: { (error) in
                    if let error = error {
                        self.present(UIAlertController.errorAlert(error: error), animated: true, completion: nil)
                    } else {
                        self.getAllInventory()
                        self.inventoryTableView.reloadData()
                    }
                })
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
}

extension InventoryViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
    }
    
}
