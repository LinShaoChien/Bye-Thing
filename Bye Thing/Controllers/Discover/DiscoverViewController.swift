//
//  DiscoverViewController.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/6/11.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Variables
    var inventories: [Inventory] = []
    
    // MARK: - View Controller Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

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
