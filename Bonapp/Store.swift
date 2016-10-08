//
//  Store.swift
//  Bonapp
//
//  Created by Jonas Larsen on 07/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

protocol Store {
    var name: String { get }
    
    func getAliasRegExps() -> [String]
    
    func getTotalRegExp() -> String
    
    
    func getProductRegExp() -> String
}
