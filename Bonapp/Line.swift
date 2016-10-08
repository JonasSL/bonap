//
//  Line.swift
//  Bonapp
//
//  Created by Jonas Larsen on 06/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

class Line {
    var words: [Word] = []
    var box: BoundingBox
    
    init(box: BoundingBox, words: [Word]) {
        self.words = words
        self.box = box
    }
    
}
