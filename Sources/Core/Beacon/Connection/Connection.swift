//
//  Connection.swift
//
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Connection types supported in Beacon.
    public enum Connection {
        
        ///
        /// P2P (Peer-to-peer) connection.
        ///
        /// - configuration: A group of values required to configure the connection.
        ///
        case p2p(_ configuration: P2PConfiguration)
        
        /// Raw type of the connection.
        public var kind: Kind {
            switch self {
            case let .p2p(content):
                return content.kind
            }
        }
        
        /// Raw values of types
        public enum Kind: String, Codable {
            case p2p
        }
        
        /// A group of values that identify the connection.
        public struct ID: Equatable, Codable {
            
            /// The type of connection the target is associated with.
            public let kind: Kind
            
            /// The unique value that identifies the target.
            public let id: String
            
            public init(kind: Connection.Kind, id: String) {
                self.kind = kind
                self.id = id
            }
            
            public init(from other: ID, id: String) {
                self.init(kind: other.kind, id: id)
            }
            
            ///
            /// Creates a P2P origin.
            ///
            /// - Parameter id: The origin identifier.
            ///
            public static func p2p(id: String) -> ID {
                .init(kind: .p2p, id: id)
            }
            
            static func p2p(id: HexString) -> ID {
                p2p(id: id.asString())
            }
        }
    }
}
