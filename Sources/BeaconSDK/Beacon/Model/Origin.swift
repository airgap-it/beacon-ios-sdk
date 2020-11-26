//
//  Origin.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public struct Origin: Equatable, Codable {
        public let kind: Connection.Kind
        public let id: String
        
        public static func p2p(id: String) -> Origin {
            Origin(kind: .p2p, id: id)
        }
        
        static func p2p(id: HexString) -> Origin {
            p2p(id: id.value())
        }
    }
}
