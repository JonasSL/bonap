//
//  Netto.swift
//  Bonapp
//
//  Created by Jonas Larsen on 07/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

class Netto: Store {
    
    func getAliasRegExps() -> [String] {
        return [".*(netto|etto|nett|nett|ett|nhiiu).*"]
    }
    
    func getTotalRegExp() -> String {
        return "(total|otal|rral|dankurt|dankort|ankort).*\\d+.*\\d+.*"
    }
    
    func getProductRegExp() -> String {
        return ""
    }
    
    var name: String = "Netto"
}
