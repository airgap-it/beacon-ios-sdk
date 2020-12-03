//
//  Origin.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// A group of values that identify the source of an incoming request.
    public struct Origin: Equatable, Codable {
        
        /// The type of connection the request originated from.
        public let kind: Connection.Kind
        
        /// The unique value that identifies the origin.
        public let id: String
        
        ///
        /// Creates a P2P origin.
        ///
        /// - Parameter id: The origin identifier.
        ///
        public static func p2p(id: String) -> Origin {
            Origin(kind: .p2p, id: id)
        }
        
        static func p2p(id: HexString) -> Origin {
            p2p(id: id.asString())
        }
    }
}
