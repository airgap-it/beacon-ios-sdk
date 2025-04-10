//
//  File.swift
//  
//
//  Created by Isacco on 21.07.23.
//

import Foundation

extension Tezos {
    public struct Threshold: Codable, Equatable {
        public let amount: String
        public let timeframe: String
    }
}
