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
        

        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: Constants.Fonts.headerFont]
        
        // Get user
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        
        // Get db ref for that user's receipts
        let userRef = FIRDatabase.database().reference(withPath: "users/\(user.uid)/receipts")
        
        // Start listener
        userRef.observe(.value, with: { snapshot in
            
            // Get list of receipts
            let newReceipts = snapshot.children.map { child in
                (child as! FIRDataSnapshot).key
            }
            
            self.receipts.removeAll()
            for receiptId in newReceipts {
                FirebaseUtility.read(receiptId: receiptId) { receipt in
                    // Remove the old with the same key
                    
//                    // FInd the old
//                    let index = self.receipts.index { receiptInArr in
//                        receiptInArr.key == receipt.key
//                    }
//                    
//                    if let i = index {
//                        self.receipts.remove(at: i)
//                    }
//                    
                    // Insert receipt and reload table
                    self.receipts.append(receipt)
                    self.tableView.reloadSections([0], with: .automatic)
                }
            }
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
        cell.textLabel?.font = Constants.Fonts.textFont

        cell.detailTextLabel?.text = receipt.total?.description ?? "Unknown"
        cell.detailTextLabel?.font = Constants.Fonts.textFont
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedReceipt = receipts[indexPath.row]
            FirebaseUtility.delete(receipt: deletedReceipt)
            receipts.remove(at: indexPath.row)
            tableView.reloadSections([0], with: .automatic)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail", let indexPath = sender as? IndexPath {
            let detailVC = segue.destination as! ReceiptDetailVC
            let selectedReceipt = receipts[indexPath.row]
            detailVC.receipt = selectedReceipt
        }
    }
}
