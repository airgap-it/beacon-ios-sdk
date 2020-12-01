//
//  PeerInfo.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public enum PeerInfo: Equatable, Hashable, Codable {
        case p2p(P2PPeerInfo)
        
        // MARK: Attributes
        
        func matches(appMetadata: AppMetadata) -> Bool {
            switch self {
            case let .p2p(content):
                return content.publicKey == appMetadata.senderID
            }
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(Beacon.Connection.Kind.self, forKey: .kind)
            switch kind {
            case .p2p:
                self = .p2p(try P2PPeerInfo(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .p2p(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case kind
        }
    }
}
