//
//  InlinedEndorsement.swift
//  
//
//  Created by Mike Godenzi on 30.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Tezos.Operation {
    
    public struct InlinedEndorsement: Codable, Equatable {
        public let branch: String
        public let operations: Content
        public let signature: String?
        
        public struct Content: Codable, Equatable {
            public let kind: Kind
            public let level: Int
        }
    }
}
