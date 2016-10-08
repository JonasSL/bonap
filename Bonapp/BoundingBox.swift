//
//  BoundingBox.swift
//  Bonapp
//
//  Created by Jonas Larsen on 06/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

class BoundingBox {
    var x: Int
    var y: Int
    var width: Int
    var height: Int
    
    init(x: Int, y: Int, width: Int, heigth: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = heigth
    }
}
