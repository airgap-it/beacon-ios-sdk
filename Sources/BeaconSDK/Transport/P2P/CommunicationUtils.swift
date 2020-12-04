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
        
        func pairingPayload(
            for peer: Beacon.P2PPeer,
            publicKey: [UInt8],
            relayServer: String,
            appName: String
        ) throws -> String {
            switch peer.version.prefix(before: ".") {
            case "1":
                return pairingPayloadV1(from: HexString(from: publicKey))
            case "2":
                return try pairingPayloadV2(
                    for: peer,
                    publicKey: HexString(from: publicKey),
                    relayServer: relayServer,
                    appName: appName
                )
            default:
                // fallback to the newest version
                return try pairingPayloadV2(
                    for: peer,
                    publicKey: HexString(from: publicKey),
                    relayServer: relayServer,
                    appName: appName
                )
            }
        }
        
        private func pairingPayloadV1(from publicKey: HexString) -> String {
            publicKey.asString()
        }
        
        private func pairingPayloadV2(
            for peer: Beacon.P2PPeer,
            publicKey: HexString,
            relayServer: String,
            appName: String
        ) throws -> String {
            guard let id = peer.id else {
                throw Beacon.Error.invalidPeer(.p2p(peer), version: peer.version)
            }
            
            let pairingResponse = PairingResponse(
                id: id,
                type: "p2p-pairing-response",
                name: appName,
                version: peer.version,
                publicKey: publicKey.asString(),
                relayServer: relayServer
            )
            let encoder = JSONEncoder()
            
            let json = String(data: try encoder.encode(pairingResponse), encoding: .utf8)
            
            return json ?? ""
        }
    }
}
