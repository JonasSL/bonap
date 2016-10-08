//
//  Receipt.swift
//  Bonapp
//
//  Created by Jonas Larsen on 08/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Receipt {
    var products: [Product] = []
    var total: Double?
    var storeName: String?
    var key: String
    let ref: FIRDatabaseReference?
    var timestamp: Date
    var timeOfPurchase: Date?
    
    init(products: [Product], total: Double?, storeName: String?, timeOfPurchase: Date? = nil, key: String = "") {
        self.products = products
        self.total = total
        self.storeName = storeName
        self.key = key
        self.ref = nil
        timestamp = Date()
        self.timeOfPurchase = timeOfPurchase
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        if let products = snapshotValue["products"] as? NSArray {
            self.products = []
            
            for child in products {
                if let productSnap = child as? FIRDataSnapshot {
                    self.products.append(Product(snapshot: productSnap))
                }
            }
        }
        total = (snapshotValue["total"] as? Double != -1) ? snapshotValue["total"] as? Double : nil
        storeName = snapshotValue["store"] as? String
        ref = snapshot.ref
        
        self.timestamp = Date(timeIntervalSince1970: TimeInterval(snapshotValue["timestamp"] as! NSNumber))
        
        if let timeInterval = snapshotValue["timeOfPurchase"] as? NSNumber , timeInterval != -1 {
            self.timeOfPurchase = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        }
    }
    
    func toAnyObject() -> Dictionary<String, Any> {
        
        return [
            "products": products.map { product in
                product.toAnyObject()
            } as NSArray,
            "total": (total ?? -1) as NSNumber,
            "store": storeName ?? "",
            "timestamp": timestamp.timeIntervalSince1970 as NSNumber,
            "timeOfPurchase": (timeOfPurchase?.timeIntervalSince1970 ?? -1) as NSNumber
        ]
    }
}
