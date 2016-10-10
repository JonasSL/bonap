//
//  FirebaseUtility.swift
//  Bonapp
//
//  Created by Jonas Larsen on 10/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUtility {
    
    static func write(receipt: Receipt) {
        // Get user
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        
        // Get a unique
        let receiptRef = FIRDatabase.database().reference(withPath: "receipts").childByAutoId()
        
        // Write to receipts
        receiptRef.setValue(receipt.toAnyObject())
        
        // Write to users
        let key = receiptRef.key
        let userRef = FIRDatabase.database().reference(withPath: "users/\(user.uid)/receipts/\(key)")
        // Set arbitrary value (key is only used for lookup
        userRef.setValue(true)
        
    }
    
    static func read(receiptId id: String, callback: @escaping (Receipt) -> ()) {
        let receiptRef = FIRDatabase.database().reference(withPath: "receipts/\(id)")
        // Observe single event and do callback
        receiptRef.observeSingleEvent(of: .value, with: { snapshot in
            callback(Receipt(snapshot: snapshot))
        })
    }
    
    static func delete(receipt: Receipt) {
        // Remove in receipt section
        receipt.ref?.removeValue()
        
        // Remove in users section
        
        guard let user = FIRAuth.auth()?.currentUser else {
            return
        }
        let userRef = FIRDatabase.database().reference(withPath: "users/\(user.uid)/receipts/\(receipt.key)")
        userRef.removeValue()
    }
}
