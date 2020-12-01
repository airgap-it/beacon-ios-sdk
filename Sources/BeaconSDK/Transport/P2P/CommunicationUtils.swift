//
//  CommunicationUtils.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    class CommunicationUtils {
        private let crypto: Crypto
        
        init(crypto: Crypto) {
            self.crypto = crypto
        }
        
        // MARK: Identifiers
        
        func recipientIdentifier(for publicKey: HexString, on relayServer: String) throws -> String {
            let hash = HexString(from: try crypto.hash(key: publicKey)).asString()
            
            return "@\(hash):\(relayServer)"
        }
        
        func recipientIdentifier(for publicKey: HexString, on relayServer: URL) throws -> String {
            try recipientIdentifier(for: publicKey, on: relayServer.host ?? "")
        }
        
        // MARK: Text Message
        
        func isMessage(_ message: Matrix.Event.TextMessage, from publicKey: HexString) -> Bool {
            do {
                let hash = try crypto.hash(key: try publicKey.asBytes())
                return message.sender.starts(with: "@\(HexString(from: hash).asString())")
            } catch {
                return false
            }
        }
        
        // MARK: Channel Open Message
        
        func channelOpeningMessage(to recipient: String, withPayload payload: String) -> String {
            "@channel-open:\(recipient):\(payload)"
        }
        
        // MARK: Pairing Payload
        
        func pairingPayload(from publicKey: [UInt8], on relayServer: String, appName: String, version: String?) throws -> String {
            guard let version = version else {
                return pairingPayloadV1(from: HexString(from: publicKey))
            }
            
            switch version.prefix(before: ".") {
            case "1":
                return pairingPayloadV1(from: HexString(from: publicKey))
            case "2":
                return try pairingPayloadV2(from: HexString(from: publicKey), on: relayServer, appName: appName, version: version)
            default:
                // fallback to the newest version
                return try pairingPayloadV2(from: HexString(from: publicKey), on: relayServer, appName: appName, version: version)
            }
        }
        
        private func pairingPayloadV1(from publicKey: HexString) -> String {
            publicKey.asString()
        }
        
        private func pairingPayloadV2(from publicKey: HexString, on relayServer: String, appName: String, version: String) throws -> String {
            let handshakeInfo = HandshakeInfo(name: appName, version: version, publicKey: publicKey.asString(), relayServer: relayServer)
            let encoder = JSONEncoder()
            
            let json = String(data: try encoder.encode(handshakeInfo), encoding: .utf8)
            
            return json ?? ""
        }
    }
}
