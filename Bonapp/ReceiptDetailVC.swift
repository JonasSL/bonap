//
//  TableViewController.swift
//  Bonapp
//
//  Created by Jonas Larsen on 08/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class ReceiptDetailVC: FormViewController {

    var receipt: Receipt!
    var groups: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get user
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        
        getGroupsFor(user: user.uid) { groups in
            self.groups = groups
        }
        
        navigationItem.title = "Detaljer"
        form +++
            Section("Information")
            <<< TextRow("Butik"){ row in
                row.title = row.tag
                row.value = receipt.storeName
                row.placeholder = "Ukendt"
            }
        
            <<< DecimalRow("Total"){ row in
                row.title = row.tag
                row.value = receipt.total
                row.placeholder = "Ukendt"
            }
        
            <<< DateRow(){ row in
                row.title = "Oprettet"
                row.value = receipt.timestamp
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                row.dateFormatter = formatter
            }
        
        if !receipt.products.isEmpty {
            form +++ Section("Produkter")
        }
        
        for product in receipt.products {
            form.last! <<< TextRow(){ row in
                row.title = product.name ?? "Ukendt"
                row.value = "\(product.price ?? 0)"
                row.disabled = true
            }
        }
        
    }
    
    private func getGroupsFor(user uid: String, completion: @escaping (([String]) -> ())) {
        // Get user ref
        let userRef = FIRDatabase.database().reference(withPath: "users/\(uid)/groups")
        
        userRef.observe(.value, with: { snapshot in
            // Get list of groups for user
            let groups = snapshot.children.map { child in
                (child as! FIRDataSnapshot).key
            }
            
           completion(groups)
        })
    }
    
    @IBAction func didPressAdd(_ sender: AnyObject) {
        // Get groups for user
        
        //Prompt user for options
        let alert = UIAlertController(title: "Add receipt to group", message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height, width: 1.0, height: 1.0)
        alert.popoverPresentationController?.sourceView = self.view

        for group in groups {
            alert.addAction(UIAlertAction(title: group, style: .default, handler: {_ in
                FirebaseUtility.write(receipt: self.receipt, toGroupId: group)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}




