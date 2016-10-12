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
    
    //MARK: - Write
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
    
    static func write(receipt: Receipt, toGroupId groupId: String) {
        // Get a unique
        let receiptRef = FIRDatabase.database().reference(withPath: "groups/\(groupId)/receipts/\(receipt.key)")
        
        // Set arbitrary value for the key
        receiptRef.setValue(true)
    }
    
    //MARK: - Read
    
    static func read(receiptId: String, callback: @escaping (Receipt) -> ()) {
        
        let receiptRef = FIRDatabase.database().reference(withPath: "receipts/\(receiptId)")
        // Observe single event and do callback
        receiptRef.observeSingleEvent(of: .value, with: { snapshot in
            callback(Receipt(snapshot: snapshot))
        })
    }
    
    static func read(groupId: String, callback: @escaping (Group) -> ()) {
        
        let receiptRef = FIRDatabase.database().reference(withPath: "groups/\(groupId)")
        // Observe single event and do callback
        receiptRef.observeSingleEvent(of: .value, with: { snapshot in
            callback(Group(snapshot: snapshot))
        })
    }
    
    static func read<T: FirebaseModel>(id: String, callback: @escaping (T) -> ()) {
        
        var path = ""
        
        if type(of: T.self) == Group.self {
            path = "groups/\(id)"
        } else if type(of: T.self) == Receipt.self {
            path = "receipts/\(id)"
        }
        
        let receiptRef = FIRDatabase.database().reference(withPath: path)
        // Observe single event and do callback
        receiptRef.observeSingleEvent(of: .value, with: { snapshot in
            callback(T(snapshot: snapshot))
        })
    }
    
    //MARK: - Delete
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
