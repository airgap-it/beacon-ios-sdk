//
//  MichelinePrim.swift
//  
//
//  Created by Mike Godenzi on 22.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Micheline {
    
    public struct Prim: Codable, Hashable, Equatable {
        public let prim: String
        public let args: [MichelsonV1Expression]?
        public let annots: [String]?
        
        public init(prim: String, args: [MichelsonV1Expression]? = nil, annots: [String]? = nil) {
            self.prim = prim
            self.args = args
            self.annots = annots
        }
    }
}
