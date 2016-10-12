//
//  Receipt.swift
//  Bonapp
//
//  Created by Jonas Larsen on 08/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Receipt: FirebaseModel {
    var products: [Product] = []
    var total: Double?
    var storeName: String?
    var key: String
    let ref: FIRDatabaseReference?
    var timestamp: Date
    var timeOfPurchase: Date?
    var ownerUid: String
    
    
    init(products: [Product], total: Double?, storeName: String?, ownerUid: String, timeOfPurchase: Date? = nil, key: String = "") {
        self.products = products
        self.total = total
        self.storeName = storeName
        self.key = key
        self.ref = nil
        timestamp = Date()
        self.timeOfPurchase = timeOfPurchase
        self.ownerUid = ownerUid
    }
    
    required init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        if let products = snapshotValue["products"] as? NSArray {
            self.products = []
            
            for child in products {
                if let dictionary = child as? NSDictionary {
                    self.products.append(Product(dict: dictionary))
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
        
        self.ownerUid = snapshotValue["ownerUid"] as! String
    }
    
    func toAnyObject() -> Dictionary<String, Any> {
        
        return [
            "products": products.map { product in
                product.toAnyObject()
            } as NSArray,
            "total": (total ?? -1) as NSNumber,
            "store": storeName ?? "",
            "ownerUid": ownerUid,
            "timestamp": timestamp.timeIntervalSince1970 as NSNumber,
            "timeOfPurchase": (timeOfPurchase?.timeIntervalSince1970 ?? -1) as NSNumber
        ]
    }
}
