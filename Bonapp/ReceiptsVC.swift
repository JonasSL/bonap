//
//  ReceiptsVC.swift
//  Bonapp
//
//  Created by Jonas Larsen on 08/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Firebase

class ReceiptsVC: UITableViewController {

    var receipts: [Receipt] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.clearsSelectionOnViewWillAppear = true
        
        // Get user
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        
        // Get db ref for that user
        let userRef = FIRDatabase.database().reference(withPath: user.uid)
        
        // Start listener
        userRef.observe(.value, with: { snapshot in
            
            let newReceipts = snapshot.children.map { child in
                Receipt(snapshot: child as! FIRDataSnapshot)
            }
            
            self.receipts = newReceipts
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return receipts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "receiptCell", for: indexPath)

        let receipt = receipts[indexPath.row]
        cell.textLabel?.text = receipt.storeName != "" ? receipt.storeName : "unknown"
        cell.detailTextLabel?.text = receipt.total?.description ?? "Unknown"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail", let indexPath = sender as? IndexPath {
            let detailVC = segue.destination as! ReceiptDetailVC
            let selectedReceipt = receipts[indexPath.row]
            detailVC.receipt = selectedReceipt
        }
    }
}
