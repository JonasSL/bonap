//
//  Word.swift
//  Bonapp
//
//  Created by Jonas Larsen on 06/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

class Word {
    var box: BoundingBox
    var text: String
    
    init(box: BoundingBox, text: String) {
        self.box = box
        self.text = text
    }
}
