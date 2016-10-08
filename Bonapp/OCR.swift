//
//  OCR.swift
//  Bonapp
//
//  Created by Jonas Larsen on 07/10/2016.
//  Copyright © 2016 Jonas Larsen. All rights reserved.
//

import Foundation

class OCR {
    
    
    static func getStores(_ text: String) -> [Store] {
        
        // Extract lines
        let lines = text.components(separatedBy: "\n")
        
        // Get all stores
        let stores: [Store] = [Føtex(), Netto()]
        
        // Initialise empty list for results
        var matchingStores: [Store] = []
        for store in stores {
            
            // Try to make all regex from that store
            let regexps = store.getAliasRegExps().map { pattern in
                try? NSRegularExpression(pattern: pattern, options: [NSRegularExpression.Options.caseInsensitive])
            }
            
            // Get an array of how many matches the lines have for each regex
            let matchingCount = lines.flatMap { line in
                // Find matches for each regex for this line
                regexps.map { regexp in
                    // Find matches between this line and this regex
                    regexp?.numberOfMatches(in: line, options: [], range: NSMakeRange(0, line.characters.count)) ?? 0
                }
            }
            
            // Get total count by summing the array (fold)
            let totalCount = matchingCount.reduce(0) { result, current in
                result + current
            }
            
            // If there is any matches, add the store to the results
            if totalCount > 0 {
                matchingStores.append(store)
            }
        }
        
        return matchingStores
    }
    
    static func getTotalAmount(_ text: String, store: Store?) -> [Double] {
        
        let generalPattern = "(total|otal|rral|dankurt|dankort|ankort).*\\d+.*\\d+.*"
        
        let pattern = store?.getTotalRegExp() ?? generalPattern
        
        // Extract lines
        let lines = text.components(separatedBy: "\n")
        
        let results = lines.flatMap { line in
            matches(for: pattern, in: line)
        }
        
        debugPrint(results)
        let numbers = results.flatMap { res in
            extractNumberFrom(line: res)
        }
        
        return numbers
    }
    
    static func getProducts(from text: String, store: Store?) -> [Product] {
        
        let generalPattern = "[\\w\\\\d]+\\s*\\d+.{1}\\d+$"
        
        
        let pattern =  generalPattern
        
        // Extract lines
        let lines = text.components(separatedBy: "\n")
        
        let results = lines.flatMap { line in
            matches(for: pattern, in: line)
        }

        var products: [Product] = []
        for res in results {
            let productName = extractProductStringFrom(line: res)
            let amount = extractNumberFrom(line: res).first
            
            guard productName != nil && amount != nil && productName != "" else {
                continue
            }
            
            let product = Product(price: amount, name: productName)
            
            products.append(product)
        }
        
        return products
    }
    
    static func extractNumberFrom(line text: String) -> [Double] {
        
        let doubleRegex = "\\d+.+\\d+"
        var doubles = matches(for: doubleRegex, in: text)
        
        doubles = doubles.map { str in
            str.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")
        }
        
        let resList = doubles.flatMap { double in
            Double(double)
        }
        
        return resList.unique
    }
    
    static func extractProductStringFrom(line text: String) -> String? {
        
        let stringRegex = "[a-å]+"
        let match = matches(for: stringRegex, in: text)
        return match.reduce("") { result, current in
            result + current
        }
    }
    
    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [NSRegularExpression.Options.caseInsensitive])
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
