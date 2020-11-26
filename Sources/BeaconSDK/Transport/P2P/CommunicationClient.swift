//
//  CommunicationClient.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    class CommunicationClient {
        private let appName: String
        private let communicationUtils: CommunicationUtils
        private let serverUtils: ServerUtils
        private let matrixClients: [Matrix]
        private let replicationCount: Int
        private let crypto: Crypto
        private let keyPair: KeyPair
        
        private var listeners: [HexString: (Matrix.Event) -> ()] = [:]
        private var serverSessionKeyPair: [HexString: SessionKeyPair] = [:]
        private var clientSessionKeyPair: [HexString: SessionKeyPair] = [:]
        
        init(
            appName: String,
            communicationUtils: CommunicationUtils,
            serverUtils: ServerUtils,
            matrixClients: [Matrix],
            replicationCount: Int,
            crypto: Crypto,
            keyPair: KeyPair
        ) {
            self.appName = appName
            self.communicationUtils = communicationUtils
            self.serverUtils = serverUtils
            self.matrixClients = matrixClients
            self.replicationCount = replicationCount
            self.crypto = crypto
            self.keyPair = keyPair
        }
        
        func start(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            do {
                let loginDigest = try crypto.hash(message: "login:\(Date().currentTimeMillis / 1000 / (5 * 60))", size: 32)
                let signature = HexString(from: try crypto.signDetached(message: loginDigest, with: keyPair.secretKey)).value()
                let publicKeyHex = HexString(from: keyPair.publicKey).value()
                let id = HexString(from: try crypto.hash(key: keyPair.publicKey)).value()
                
                let password = "ed:\(signature):\(publicKeyHex)"
                let deviceID = publicKeyHex
                
                matrixClients.awaitAll(
                    async: { $0.start(userID: id, password: password, deviceID: deviceID, completion: $1) },
                    completion: completion
                )
            } catch {
                completion(.failure(error))
            }
        }
        
        // MARK: Incoming Messages
        
        func listen(to publicKey: HexString, listener: @escaping (Result<String, Swift.Error>) -> ()) {
            guard listeners[publicKey] == nil else {
                return
            }
            
            let textMessageListener: (Matrix.Event) -> () = { [weak self] event in
                if let selfStrong = self {
                    guard let textMessage = selfStrong.textMessage(from: event, sender: publicKey) else {
                        return
                    }
                    
                    listener(catchResult { try selfStrong.decrypt(message: textMessage, with: publicKey) })
                }
            }
            
            listeners[publicKey] = textMessageListener
            matrixClients.forEach { $0.subscribe(for: .textMessage, listener: textMessageListener) }
        }
        
        private func textMessage(from event: Matrix.Event, sender publicKey: HexString) -> Matrix.Event.TextMessage? {
            switch event {
            case let .textMessage(message):
                guard communicationUtils.isMessage(message, from: publicKey) && crypto.validate(encrypted: message.message) else {
                    return nil
                }
                
                return message
            default:
                return nil
            }
        }
        
        private func decrypt(message encrypted: Matrix.Event.TextMessage, with publicKey: HexString) throws -> String {
            let keyPair = try getOrCreateServerSessionKeyPair(for: publicKey)
            
            let decrypted: [UInt8] = try {
                if encrypted.message.isHex {
                    return try crypto.decrypt(message: try HexString(from: encrypted.message), withSharedKey: keyPair.rx)
                } else {
                    return try crypto.decrypt(message: encrypted.message, withSharedKey: keyPair.rx)
                }
            }()
                
            return String(bytes: decrypted, encoding: .utf8) ?? ""
        }
        
        private func getOrCreateServerSessionKeyPair(for publicKey: HexString) throws -> SessionKeyPair {
            try serverSessionKeyPair.getOrSet(publicKey) {
                try crypto.serverSessionKeyPair(publicKey: publicKey.bytes(), secretKey: keyPair.secretKey)
            }
        }
        
        // MARK: Outgoing Messages
        
        func send(message: String, to publicKey: HexString, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            do {
                let encrypted = HexString(from: try encrypt(message: message, with: publicKey)).value()
                for i in 0..<replicationCount {
                    let relayServer = try serverUtils.relayServer(for: publicKey, nonce: try HexString(from: i))
                    let recipient = try communicationUtils.recipientIdentifier(for: publicKey, on: relayServer)
                    
                    matrixClients.awaitAll(async: { $0.send(textMessage: encrypted, to: recipient, completion: $1) }, completion: completion)
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        func sendPairingRequest(
            to publicKey: HexString,
            on relayServer: String,
            version: String?,
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            do {
                let recipient = try communicationUtils.recipientIdentifier(for: publicKey, on: relayServer)
                let pairingPayload = try communicationUtils.pairingPayload(
                    from: keyPair.publicKey,
                    on: try serverUtils.relayServer(for: keyPair.publicKey).absoluteString,
                    appName: appName,
                    version: version
                )
                
                let payload = HexString(from: try crypto.encrypt(message: pairingPayload, withPublicKey: try publicKey.bytes())).value()
                let message = communicationUtils.channelOpeningMessage(to: recipient, withPayload: payload)
                
                matrixClients.awaitAll(async: { $0.send(textMessage: message, to: recipient, completion: $1) }, completion: completion)
            } catch {
                completion(.failure(error))
            }
        }
        
        private func encrypt(message: String, with publicKey: HexString) throws -> [UInt8] {
            let keyPair = try getOrCreateClientSessionKeyPair(for: publicKey)
            
            return try crypto.encrypt(message: message, withSharedKey: keyPair.tx)
        }
        
        private func getOrCreateClientSessionKeyPair(for publicKey: HexString) throws -> SessionKeyPair {
            try clientSessionKeyPair.getOrSet(publicKey) {
                try crypto.clientSessionKeyPair(publicKey: publicKey.bytes(), secretKey: keyPair.secretKey)
            }
        }
    }
}

// MARK: Extensions

extension Matrix {
    
    func send(textMessage message: String, to recipient: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        getRelevantRoom(withMember: recipient) { result in
            guard let roomOrNil = result.get(ifFailure: completion) else { return }
            
            guard let room = roomOrNil else {
                completion(.failure(Error.relevantRoomNotFound))
                return
            }
            
            self.send(message: message, to: room, completion: completion)
        }
    }
    
    func getRelevantRoom(withMember member: String, completion: @escaping (Result<Matrix.Room?, Swift.Error>) -> ()) {
        joinedRooms {
            guard let joined = $0.get(ifFailure: completion) else { return }
            if let room = joined.first(where: { $0.members.contains(member) }) {
                completion(.success(room))
            } else {
                self.createTrustedPrivateRoom(invitedMembers: [member], completion: completion)
            }
        }
    }
}
