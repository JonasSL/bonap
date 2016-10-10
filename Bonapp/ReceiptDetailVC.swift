//
//  TableViewController.swift
//  Bonapp
//
//  Created by Jonas Larsen on 08/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import UIKit
import Eureka

class ReceiptDetailVC: FormViewController {

    var receipt: Receipt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
}

    


