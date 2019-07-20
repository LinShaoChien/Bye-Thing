//
//  HistoryViewController.swift
//  Bye Thing
//
//  Created by Shao-Chien Lin on 2019/7/13.
//  Copyright © 2019 l.shaochien. All rights reserved.
//

import UIKit
import FirebaseFirestore

class HistoryViewController: UIViewController {

    // MARK: - Variables
    var documents: [DocumentSnapshot]!
    var inventoryID: String!
    
    // MARK: - Outlets
    @IBOutlet weak var bidTableView: UITableView!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bidTableView.delegate = self
        bidTableView.dataSource = self
        
    }

}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bidTableViewCell", for: indexPath) as! BidTableViewCell
        cell.configureCell(documents: self.documents, indexPath: indexPath)
        return cell
    }
    
}
