//
//  Group.swift
//  Bonapp
//
//  Created by Jonas Larsen on 10/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation
import Firebase

class Group : FirebaseModel {
    var users: [String]
    var receipts: [String]
    var key: String
    let ref: FIRDatabaseReference?
    
    init(users: [String], receipts: [String]) {
        self.users = users
        self.receipts = receipts
        key = ""
        ref = nil
    }
    
    required init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        ref = snapshot.ref

        let snapshotValue = snapshot.value as! [String: AnyObject]
        
        self.receipts = snapshot.childSnapshot(forPath: "receipts").children.map { child in
            (child as! FIRDataSnapshot).key
        }
        
        self.users = snapshot.childSnapshot(forPath: "users").children.map { child in
            (child as! FIRDataSnapshot).key
        }
        
    }
    
    func toAnyObject() -> Dictionary<String, Any> {
        let userDict = users.map { user in
            [user : true]
        }
        let receiptDict = receipts.map { receipt in
            [receipt : true]
        }
        
        return [
            "users": userDict,
            "receipts": receiptDict
        ]
    }
}
