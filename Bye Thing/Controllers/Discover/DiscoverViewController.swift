//
//  DiscoverViewController.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/11.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DiscoverViewController: UIViewController {
    
    // MARK: - Subviews
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var inventoryTypeCollectionView: UICollectionView!
    @IBOutlet weak var inventoryTypeCollectionViewFlowLayout: UICollectionViewFlowLayout! {
        didSet {
            inventoryTypeCollectionViewFlowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    var indicator: UIActivityIndicatorView!

    // MARK: - Variables
    var inventories: [Inventory] = []
    var documents: [DocumentSnapshot] = []
    var currentSelectedCellIndexPath: IndexPath? = nil
    
    // MARK: - Flags
    var isPrefetching = false
    var isAllDataFetched = false
    
    // MARK: - Segues
    enum Segue {
        static let toDetail = "toDetail"
    }
    
    // MARK: - View Controller Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        inventoryTypeCollectionView.delegate = self
        inventoryTypeCollectionView.dataSource = self
        tableView.prefetchDataSource = self
        configureActivityIndicator()
        getInventories()
        setupNavigationBar()
    }
    
    // MARK: - UIActions
    @IBAction func searchPressed(_ sender: Any) {
        getInventories()
    }
    
    // MARK: -
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.toDetail {
            let destination = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let inventory = inventories[indexPath.row]
            destination.inventoryName = inventory.name
            destination.inventoryImageURL = inventory.imageurl
            destination.inventoryDescription = inventory.description
            destination.inventoryID = inventory.id
        }
    }
    
    // MARK: -
    func setupNavigationBar() {
        navigationItem.title = "Discover"
        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0.2979793549, blue: 0, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 5/255, green: 61/255, blue: 0/255, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "Montserrat-Regular", size: 18)!
        ]
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
        
        let limit = 10
        
        var type: InventoryType? = nil
        var name: String? = nil
        
        if let indexPath = currentSelectedCellIndexPath {
            print("DID SELECT TYPE")
            type = INVENTORY_TYPES[indexPath.item]
        }
        
        if let searchName = searchTextField.text, searchTextField.text != "" {
            print("HAS NAME")
            name = searchName
        }
        
        FirestoreServices.sharedInstance.getInventories(ofUser: nil, type: type, name: name, limit: limit, after: nil) { (inventories, documents, error) in
            if let error = error {
                let alert = UIAlertController.errorAlert(error: error)
                self.indicator.stopAnimating()
                self.present(alert, animated: true, completion: nil)
            } else {
                self.indicator.stopAnimating()
                if let inventories = inventories, let documents = documents {
                    if inventories.count < limit {
                        self.isAllDataFetched = true
                    } else {
                        self.isAllDataFetched = false
                    }
                    self.inventories = inventories
                    self.documents = documents
                    self.tableView.reloadData()
                    
                    guard inventories.count != 0 else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
        }
    }
    
    // MARK: - Prefetch
    func prefetch(indexPaths: [IndexPath]) {
        let limit = 10
        
        for indexPath in indexPaths {
            
            if indexPath.row + 1 >= self.documents.count && !isPrefetching {
                
                isPrefetching = true
                FirestoreServices.sharedInstance.getInventories(ofUser: nil, type: nil, name: nil, limit: limit, after: documents.last) { (inventories, documents, error) in
                    if let error = error {
                        let alert = UIAlertController.errorAlert(error: error)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        for inventory in inventories! {
                            self.inventories.append(inventory)
                        }
                        for document in documents! {
                            self.documents.append(document)
                        }
                        if inventories!.count < limit {
                            self.isAllDataFetched = true
                        }
                        self.isPrefetching = false
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inventories.count == 0 {
            return 0
        } else if isAllDataFetched == true {
            return inventories.count
        }
        return inventories.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "inventoryCell", for: indexPath) as! InventoryTableViewCell
        cell.configureCell(inventories: inventories, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: Segue.toDetail, sender: indexPath)
    }

}

extension DiscoverViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        if isAllDataFetched == false {
            prefetch(indexPaths: indexPaths)
        }
    }
    
}

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return INVENTORY_TYPES.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inventoryTypeCell", for: indexPath) as! InventoryTypeCollectionViewCell
        let typeName = INVENTORY_TYPES[indexPath.item].name
        cell.configureCell(typeName: typeName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InventoryTypeCollectionViewCell
        
        if let selectedIndexPath = currentSelectedCellIndexPath {
            if indexPath == selectedIndexPath {
                currentSelectedCellIndexPath = nil
                collectionView.deselectItem(at: indexPath, animated: true)
                cell.setStyle()
            } else {
                currentSelectedCellIndexPath = indexPath
                cell.setStyle()
            }
        } else {
            currentSelectedCellIndexPath = indexPath
            cell.setStyle()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! InventoryTypeCollectionViewCell
        print("Deselect at \(indexPath.item)")
        cell.setStyle()
    }
}

