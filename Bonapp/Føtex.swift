//
//  Føtex.swift
//  Bonapp
//
//  Created by Jonas Larsen on 07/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

class Føtex: Store {
    
    var name: String = "Føtex"
    
    func getAliasRegExps() -> [String] {
        return [".*(fotex|foetex|føtex|fctex|fttex|oetex|etex|føte|foete|f¢tex).*"]
    }
    
    func getProductRegExp() -> String {
        return ""
    }
    
    func getTotalRegExp() -> String {
        return "(total|otal|rral|dankurt|dankort|ankort).*\\d+.*\\d+.*"
    }
}
