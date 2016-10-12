//
//  Extensions.swift
//  Bonapp
//
//  Created by Jonas Larsen on 07/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

//http://stackoverflow.com/questions/27624331/unique-values-of-array-in-swift
extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

extension Date {
    func formatted(withDateStyle dateStyle: DateFormatter.Style, andTimeStyle timeStyle: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = timeStyle
        formatter.dateStyle = dateStyle
        return formatter.string(from: self)
    }
}
