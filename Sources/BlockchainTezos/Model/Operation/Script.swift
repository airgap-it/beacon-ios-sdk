//
//  Script.swift
//  
//
//  Created by Julia Samol on 17.05.22.
//

import Foundation

extension Tezos.Operation {
    
    public struct Script: Codable, Equatable {
        public let code: Micheline.MichelsonV1Expression
        public let storage: Micheline.MichelsonV1Expression
        
        public init(code: Micheline.MichelsonV1Expression, storage: Micheline.MichelsonV1Expression) {
            self.code = code
            self.storage = storage
        }
    }
}
