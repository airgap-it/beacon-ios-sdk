//
//  P2PMatrixCommunicator.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
extension Transport.P2P.Matrix {
    
    class Communicator {
        private let app: Beacon.Application
        private let crypto: Crypto
        
        private var keyPair: KeyPair { app.keyPair }
        
        init(app: Beacon.Application, crypto: Crypto) {
            self.app = app
            self.crypto = crypto
        }
        
        // MARK: Identifiers
        
        func recipientIdentifier(for publicKey: [UInt8], on relayServer: String) throws -> Transport.P2P.Identifier {
            let hash = try crypto.hash(key: publicKey)
            
            return .init(publicKeyHash: hash, relayServer: relayServer)
        }
        
        // MARK: Text Message
        
        func isMessage(_ message: MatrixClient.Event.TextMessage, from publicKey: [UInt8]) -> Bool {
            do {
                let hash = try crypto.hash(key: publicKey)
                return message.sender.starts(with: "@\(HexString(from: hash).asString())")
            } catch {
                return false
            }
        }
        
        func isValidMessage(_ message: MatrixClient.Event.TextMessage) -> Bool {
            crypto.validate(encrypted: message.message)
        }
        
        // MARK: Channel Open Message
        
        private static let channelOpeningMessageHeader: String = "@channel-open"
        private static let channelOpeningMessageSeparator: String = ":"
        
        func channelOpeningMessage(to recipient: String, withPayload payload: String) -> String {
            "\(Self.channelOpeningMessageHeader)\(Self.channelOpeningMessageSeparator)\(recipient)\(Self.channelOpeningMessageSeparator)\(payload)"
        }
        
        func recognizeChannelOpeningMessage(_ message: String) -> Bool {
            message.hasPrefix(Self.channelOpeningMessageHeader)
        }
        
        func destructChannelOpeningMessage(_ message: String) throws -> (String, String) {
            guard recognizeChannelOpeningMessage(message) else {
                throw Error.invalidChannelOpeningMessage
            }
            
            let components = message.split(separator: .init(Self.channelOpeningMessageSeparator))
            guard components.count >= 3 else {
                throw Error.invalidChannelOpeningMessage
            }
            
            let recipient = components[1..<(components.count - 1)].joined(separator: Self.channelOpeningMessageSeparator)
            let payload = String(components[components.count - 1])
            
            return (recipient, payload)
        }
        
        // MARK: Pairing
        
        func pairingRequest(relayServer: String) throws -> Transport.P2P.PairingRequest {
            .init(
                id: try crypto.guid(),
                name: app.name,
                version: Beacon.Configuration.beaconVersion,
                publicKey: HexString(from: keyPair.publicKey).asString(),
                relayServer: relayServer,
                icon: app.icon,
                appURL: app.url
            )
        }
        
        func pairingResponse(from request: Transport.P2P.PairingRequest, relayServer: String) -> Transport.P2P.PairingResponse {
            .init(
                id: request.id,
                name: app.name,
                version: Beacon.Configuration.beaconVersion,
                publicKey: HexString(from: keyPair.publicKey).asString(),
                relayServer: relayServer,
                icon: app.icon,
                appURL: app.url
            )
        }
        
        func pairingResponse(fromPayload payload: String) -> Transport.P2P.PairingResponse {
            let decoder = JSONDecoder()
            if let pairingResponse = try? decoder.decode(Transport.P2P.PairingResponse.self, from: Data(payload.utf8)) {
                return pairingResponse
            } else /* v1 */ {
                return .init(id: "", name: "", version: "", publicKey: payload, relayServer: "", icon: nil, appURL: nil)
            }
        }
        
        func pairingResponsePayload(for peer: Beacon.P2PPeer, relayServer: String) throws -> String {
            let request = try Transport.P2P.PairingRequest(from: peer)
            let response = pairingResponse(from: request, relayServer: relayServer)
            
            switch response.version.prefix(before: ".") {
            case "1":
                return pairingPayloadV1(from: response)
            case "2":
                return try pairingPayloadV2(from: response, relayServer: relayServer)
            case "3":
                return try pairingPayloadV3(from: response, relayServer: relayServer)
            default:
                // fallback to the newest version
                return try pairingPayloadV3(from: response, relayServer: relayServer)
            }
        }
        
        private func pairingPayloadV1(from response: Transport.P2P.PairingResponse) -> String {
            response.publicKey
        }
        
        private func pairingPayloadV2(from response: Transport.P2P.PairingResponse, relayServer: String) throws -> String {
            let encoder = JSONEncoder()
            guard let json = String(data: try encoder.encode(response), encoding: .utf8) else {
                throw Beacon.Error.unknown("Failed to decode JSON string while preparing P2P pairing payload.")
            }
            
            return json
        }
        
        private func pairingPayloadV3(from response: Transport.P2P.PairingResponse, relayServer: String) throws -> String {
            try pairingPayloadV2(from: response, relayServer: relayServer)
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case invalidChannelOpeningMessage
        }
    }
}

private extension Transport.P2P.PairingRequest {
    init(from peer: Beacon.P2PPeer) throws {
        guard let id = peer.id else {
            throw Beacon.Error.invalidPeer(.p2p(peer), version: peer.version)
        }
        
        self.init(
            id: id,
            name: peer.name,
            version: peer.version,
            publicKey: peer.publicKey,
            relayServer: peer.relayServer,
            icon: peer.icon,
            appURL: peer.appURL?.absoluteString
        )
    }
}
