//
//  String+Additions.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public extension String {
    
    var isHex: Bool {
        range(of: "^(\(HexString.prefix))?([0-9a-fA-F]{2})*$", options: .regularExpression) != nil
    }
    
    func prefix(before separator: Character) -> String {
        String(prefix { $0 != separator })
    }
    
    func removing(prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }
        
        let index = index(startIndex, offsetBy: prefix.count)
        return String(self[index...])
    }
    
    func removing(prefix: Character) -> String {
        removing(prefix: String(prefix))
    }
}
