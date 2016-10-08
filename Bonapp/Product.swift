//
//  Product.swift
//  Bonapp
//
//  Created by Jonas Larsen on 07/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Product {
    var price: Double?
    var name: String?
    var key: String
    let ref: FIRDatabaseReference?

    
    var description: String {
        get {
            return "\(name ?? "ukendt") der koster " + (price != nil ? String(describing: price!) : "ukendt")
        }
    }
    
    init(price: Double?, name: String?, key: String = "") {
        self.price = price
        self.name = name
        self.key = key
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as? String
        price = snapshotValue["price"] as? Double
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Dictionary<String, Any> {
        let nameToSave = name ?? ""
        let priceToSave = price ?? -1
        
        return [
            "name": nameToSave,
            "price": priceToSave
        ]
    }
    
}
