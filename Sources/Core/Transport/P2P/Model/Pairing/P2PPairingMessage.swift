//
//  P2PPairingMessage.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

extension Transport.P2P {
    
    public enum PairingMessage: Hashable, Codable, TransportP2PPairingMessageProtocol {
        case request(PairingRequest)
        case response(PairingResponse)
        
        public enum Kind: String, Codable {
            case request = "p2p-pairing-request"
            case response = "p2p-pairing-response"
        }
        
        // MARK: Attributes
        
        public var id: String {
            common.id
        }
        
        public var name: String {
            common.name
        }
        
        public var version: String {
            common.version
        }
        
        public var publicKey: String {
            common.publicKey
        }
        
        public var relayServer: String {
            common.relayServer
        }
        
        public var icon: String? {
            common.icon
        }
        
        public var appURL: String? {
            common.appURL
        }
        
        private var common: TransportP2PPairingMessageProtocol {
            switch self {
            case let .request(content):
                return content
            case let .response(content):
                return content
            }
        }
        
        public func toPeer() -> Beacon.Peer {
            common.toPeer()
        }
        
        // MARK: Codable
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try container.decode(Kind.self, forKey: .type)
            switch type {
            case .request:
                self = .request(try .init(from: decoder))
            case .response:
                self = .response(try .init(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
            case let .request(content):
                try content.encode(to: encoder)
            case let .response(content):
                try content.encode(to: encoder)
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case type
        }
    }
}

public protocol TransportP2PPairingMessageProtocol: BeaconPairingMessageProtocol {
    var relayServer: String { get }
    var icon: String? { get }
    var appURL: String? { get }
}
