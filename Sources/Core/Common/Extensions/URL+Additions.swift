//
//  URL+Additions.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public extension URL {
    init?(string: String?) {
        guard let string = string else {
            return nil
        }
        
        self.init(string: string)
    }
}
