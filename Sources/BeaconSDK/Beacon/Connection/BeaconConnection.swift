//
//  BeaconConnection.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public enum Connection: Equatable, Hashable {
        case p2p(P2PConfiguration = P2PConfiguration())
        
        public var kind: Kind {
            switch self {
            case let .p2p(content):
                return content.kind
            }
        }
        
        public enum Kind: String, Codable {
            case p2p
        }
    }
}
