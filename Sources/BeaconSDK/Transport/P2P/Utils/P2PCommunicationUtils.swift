//
//  P2PCommunicationUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    struct CommunicationUtils {
        private let app: Beacon.Application
        private let crypto: Crypto
        
        private var keyPair: KeyPair { app.keyPair }
        
        init(app: Beacon.Application, crypto: Crypto) {
            self.app = app
            self.crypto = crypto
        }
        
        // MARK: Identifiers
        
        func recipientIdentifier(for publicKey: [UInt8], on relayServer: String) throws -> Identifier {
            let hash = try crypto.hash(key: publicKey)
            
            return Identifier(publicKeyHash: hash, relayServer: relayServer)
        }
        
        // MARK: Text Message
        
        func isMessage(_ message: Matrix.Event.TextMessage, from publicKey: [UInt8]) -> Bool {
            do {
                let hash = try crypto.hash(key: publicKey)
                return message.sender.starts(with: "@\(HexString(from: hash).asString())")
            } catch {
                return false
            }
        }
        
        func isValidMessage(_ message: Matrix.Event.TextMessage) -> Bool {
            crypto.validate(encrypted: message.message)
        }
        
        // MARK: Channel Open Message
        
        func channelOpeningMessage(to recipient: String, withPayload payload: String) -> String {
            "@channel-open:\(recipient):\(payload)"
        }
        
        // MARK: Pairing Payload
        
        func pairingPayload(
            for peer: Beacon.P2PPeer,
            relayServer: String
        ) throws -> String {
            switch peer.version.prefix(before: ".") {
            case "1":
                return pairingPayloadV1()
            case "2":
                return try pairingPayloadV2(for: peer, relayServer: relayServer)
            default:
                // fallback to the newest version
                return try pairingPayloadV2(for: peer, relayServer: relayServer)
            }
        }
        
        private func pairingPayloadV1() -> String {
            HexString(from: keyPair.publicKey).asString()
        }
        
        private func pairingPayloadV2(for peer: Beacon.P2PPeer, relayServer: String) throws -> String {
            guard let id = peer.id else {
                throw Beacon.Error.invalidPeer(.p2p(peer), version: peer.version)
            }
            
            let pairingResponse = PairingResponse(
                id: id,
                type: "p2p-pairing-response",
                name: app.name,
                version: peer.version,
                publicKey: HexString(from: keyPair.publicKey).asString(),
                relayServer: relayServer,
                icon: app.icon,
                appURL: app.url
            )
            let encoder = JSONEncoder()
            
            let json = String(data: try encoder.encode(pairingResponse), encoding: .utf8)
            
            return json ?? ""
        }
    }
}
