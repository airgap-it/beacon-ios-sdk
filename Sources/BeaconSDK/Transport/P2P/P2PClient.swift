//
//  P2PClient.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Transport.P2P {
    
    class Client {
        private let matrixClient: Matrix
        private let store: Store
        private let cryptoUtils: CryptoUtils
        private let communicationUtils: CommunicationUtils
        
        private var eventListeners: [HexString: Matrix.EventListener] = [:]
        private var internalListeners: [Matrix.EventListener] = []
        
        private let joinQueue: DispatchQueue = .init(
            label: "it.airgap.beacon-sdk.Transport.P2P.Client.join",
            attributes: [],
            target: .global(qos: .default)
        )
        
        init(
            matrixClient: Matrix,
            store: Store,
            cryptoUtils: CryptoUtils,
            communicationUtils: CommunicationUtils
        ) {
            self.matrixClient = matrixClient
            self.store = store
            self.cryptoUtils = cryptoUtils
            self.communicationUtils = communicationUtils
        }
        
        func start(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            runCatching(completion: completion) {
                let userID = try cryptoUtils.userID()
                let deviceID = try cryptoUtils.deviceID()
                
                store.state {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    self.startRepeat(userID: userID, deviceID: deviceID, retrying: state.availableNodes) { result in
                        guard result.get(ifFailure: completion) != nil else { return }
                    
                        let inviteListener = Matrix.EventListener { [weak self] event in
                            guard let selfStrong = self else { return }
                            selfStrong.store.state {
                                let state = try? $0.get()
                                guard let invite = selfStrong.invite(from: event) else { return }
                                if let activeChannel = state?.activeChannels[invite.sender], activeChannel == invite.roomID { return }
                                
                                selfStrong.store.intent(action: .onChannelEvent(sender: invite.sender, channelID: invite.roomID))
                                selfStrong.acceptInviteRepeated(joining: invite.roomID) { _ in }
                            }
                        }
                        
                        self.internalListeners.append(inviteListener)
                        self.matrixClient.subscribe(for: .invite, with: inviteListener)
                        
                        completion(.success(()))
                    }
                }
            }
        }
        
        private func startRepeat(
            userID: String,
            deviceID: String,
            retrying retry: Int,
            carrying carryError: Swift.Error? = nil,
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            guard retry >= 0 else {
                if let carryError = carryError {
                    completion(.failure(carryError))
                } else {
                    completion(.failure(Error.startFailed))
                }
                return
            }
            
            store.state {
                guard let state = $0.get(ifFailure: completion) else { return }
                
                runCatching(completion: completion) {
                    let password = try self.cryptoUtils.password()
                    
                    self.matrixClient.start(on: state.relayServer, userID: userID, password: password, deviceID: deviceID) { result in
                        guard let error = result.error else {
                            completion(.success(()))
                            return
                        }
                        
                        self.resetHard { result in
                            guard result.get(ifFailure: completion) != nil else { return }
                            self.startRepeat(userID: userID, deviceID: deviceID, retrying: retry, carrying: error, completion: completion)
                        }
                    }
                }
            }
        }
        
        private func resetHard(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            store.intent(action: .hardReset) { result in
                guard result.get(ifFailure: completion) != nil else { return }
                self.matrixClient.resetHard(completion: completion)
            }
        }
        
        // MARK: Incoming Messages
        
        func listen(to publicKey: [UInt8], listener: @escaping (Result<String, Swift.Error>) -> ()) {
            guard eventListeners[publicKey] == nil else { return }

            let textMessageListener = Matrix.EventListener { [weak self] event in
                guard let selfStrong = self else { return }
                selfStrong.store.state {
                    let state = try? $0.get()
                    if let relayServer = state?.relayServer, event.common.node != relayServer { return }
                    guard let textMessage = selfStrong.textMessage(from: event, sender: publicKey) else { return }
                    
                    selfStrong.store.intent(action: .onChannelEvent(sender: textMessage.sender, channelID: textMessage.roomID))
                    
                    listener(runCatching { try selfStrong.cryptoUtils.decrypt(message: textMessage, with: publicKey) })
                }
            }
            
            eventListeners[publicKey] = textMessageListener
            matrixClient.subscribe(for: .textMessage, with: textMessageListener)
        }
        
        func removeListener(for publicKey: HexString) {
            guard let listener = eventListeners.removeValue(forKey: publicKey) else { return }
            matrixClient.unsubscribe(listener)
            
            if eventListeners.isEmpty {
                matrixClient.stop()
            }
        }
        
        private func textMessage(from event: Matrix.Event, sender publicKey: [UInt8]) -> Matrix.Event.TextMessage? {
            switch event {
            case let .textMessage(message):
                guard communicationUtils.isMessage(message, from: publicKey) && communicationUtils.isValidMessage(message) else {
                    return nil
                }
                
                return message
            default:
                return nil
            }
        }
        
        // MARK: Outgoing Messages
        
        func send(message: String, to peer: Beacon.P2PPeer, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            runCatching(completion: completion) {
                let publicKey = try HexString(from: peer.publicKey).asBytes()
                let recipient = try self.communicationUtils.recipientIdentifier(for: publicKey, on: peer.relayServer)
                let encrypted = try self.cryptoUtils.encrypt(message: message, with: publicKey)
                
                self.matrixClient.send(
                    textMessage: HexString(from: encrypted).asString(),
                    to: recipient.asString(),
                    using: self.store,
                    completion: completion
                )
            }
        }
        
        func sendPairingResponse(
            to peer: Beacon.P2PPeer,
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            store.state {
                guard let state = $0.get(ifFailure: completion) else { return }
                
                runCatching(completion: completion) {
                    let publicKey = try HexString(from: peer.publicKey).asBytes()
                    let recipient = try self.communicationUtils.recipientIdentifier(for: publicKey, on: peer.relayServer)
                    let payload = try self.cryptoUtils.encryptPairingPayload(
                        try self.communicationUtils.pairingPayload(for: peer, relayServer: state.relayServer),
                        with: publicKey
                    )
                    let message = self.communicationUtils.channelOpeningMessage(
                        to: recipient.asString(),
                        withPayload: HexString(from: payload).asString()
                    )
                    
                    self.matrixClient.send(
                        textMessage: message,
                        to: recipient.asString(),
                        using: self.store,
                        forcingNewRoom: true,
                        completion: completion
                    )
                }
            }
        }
        
        // MARK: Invites
        
        private func invite(from event: Matrix.Event) -> Matrix.Event.Invite? {
            switch event {
            case let .invite(invite):
                return invite
            default:
                return nil
            }
        }
        
        private func acceptInviteRepeated(
            joining roomID: String,
            retrying retry: Int = Beacon.Configuration.p2pMaxJoinRetries,
            carrying carryError: Swift.Error? = nil,
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            guard retry >= 0 else {
                if let carryError = carryError {
                    completion(.failure(carryError))
                } else {
                    completion(.failure(Error.joinFailed(roomID: roomID)))
                }
                return
            }
            
            store.state {
                guard let state = $0.get(ifFailure: completion) else { return }
                self.matrixClient.joinRoom(on: state.relayServer, roomID: roomID) { joinResult in
                    guard let error = joinResult.error else {
                        completion(.success(()))
                        return
                    }
                    
                    guard (error as? Matrix.ErrorResponse)?.asForbidden() != nil else {
                        completion(.failure(error))
                        return
                    }
                    
                    // Joining a room too quickly after receiving an invite event
                    // sometimes results in rejection from the server in a federated multi-node setup.
                    // Usually waiting a few milliseconds solves the issue.
                    
                    self.joinQueue.asyncAfter(deadline: .now() + .milliseconds(Beacon.Configuration.p2pJoinDelaysMs)) { [unowned self] in
                        self.acceptInviteRepeated(joining: roomID, retrying: retry - 1, carrying: error, completion: completion)
                    }
                }
            }
        }
        
        // MARK: Types
        
        enum Error: Swift.Error {
            case startFailed
            case joinFailed(roomID: String)
        }
    }
}

// MARK: Extensions

private extension Matrix {
    
    func send(
        textMessage message: String,
        to recipient: String,
        using store: Transport.P2P.Store,
        forcingNewRoom newRoom: Bool = false,
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            
            let onRoomID: (Result<String?, Swift.Error>) -> () = { roomResult in
                guard let roomIDOrNil = roomResult.get(ifFailure: completion) else { return }
                guard let roomID = roomIDOrNil else {
                    completion(.failure(Error.relevantRoomNotFound))
                    return
                }
                
                self.send(on: state.relayServer, message: message, to: roomID) { sendResult in
                    guard let error = sendResult.error else {
                        completion(.success(()))
                        return
                    }
                    
                    guard (error as? Matrix.ErrorResponse)?.asForbidden() != nil else {
                        completion(.failure(error))
                        return
                    }
                    
                    store.intent(action: .onChannelClosed(channelID: roomID)) { intentResult in
                        guard intentResult.get(ifFailure: completion) != nil else { return }
                        
                        self.roomID(withMember: recipient, using: store) { newRoomResult in
                            guard let newRoomIDOrNil = newRoomResult.get(ifFailure: completion) else { return }
                            guard let newRoomID = newRoomIDOrNil else {
                                completion(.failure(Error.relevantRoomNotFound))
                                return
                            }
                            
                            self.send(on: state.relayServer, message: message, to: newRoomID, completion: completion)
                        }
                    }
                }
            }
            
            if newRoom {
                self.createRoom(withMember: recipient, using: store) { result in onRoomID(result.map({ $0?.id })) }
            } else {
                self.roomID(withMember: recipient, using: store, completion: onRoomID)
            }
        }
    }
    
    private func roomID(
        withMember member: String,
        using store: Transport.P2P.Store,
        completion: @escaping (Result<String?, Swift.Error>) -> ()
    ) {
        store.state {
            let state = try? $0.get()
            
            if let activeChannel = state?.activeChannels[member] {
                completion(.success(activeChannel))
                return
            }
            
            self.joinedRooms {
                guard let joined = $0.get(ifFailure: completion) else { return }
                if let room = joined.first(where: { $0.isActive(using: state) && $0.hasMember(member) }) {
                    completion(.success(room.id))
                } else {
                    self.createRoom(withMember: member, using: store) { result in
                        completion(result.map({ $0?.id }))
                    }
                }
            }
        }
    }
    
    private func createRoom(
        withMember member: String,
        using store: Transport.P2P.Store,
        completion: @escaping (Result<Matrix.Room?, Swift.Error>) -> ()
    ) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            
            self.createTrustedPrivateRoom(on: state.relayServer, invitedMembers: [member]) { roomResult in
                guard let roomOrNil = roomResult.get(ifFailure: completion) else { return }
                guard let room = roomOrNil else {
                    completion(.success(nil))
                    return
                }
                
                self.waitForMember(member, joining: room, using: store) {
                    store.intent(action: .onChannelCreated(recipient: member, channelID: room.id)) { intentResult in
                        guard intentResult.get(ifFailure: completion) != nil else { return }
                        completion(.success(room))
                    }
                }
            }
        }
    }
    
    private func waitForMember(
        _ member: String,
        joining room: Room,
        using store: Transport.P2P.Store,
        completion: @escaping () -> ()
    ) {
        if room.members.contains(member) {
            completion()
            return
        }
    
        var joinEventListener: EventListener!
        joinEventListener = EventListener { [weak self] event in
            switch event {
            case let .join(join):
                if join.roomID == room.id && join.userID == member {
                    self?.unsubscribe(joinEventListener)
                    completion()
                }
            default:
                break
            }
            
        }
        subscribe(for: .join, with: joinEventListener)
    }
}

private extension Matrix.Room {
    
    func isActive(forMember member: String, using state: Transport.P2P.Store.State?) -> Bool {
        guard let state = state else {
            return false
        }
        
        return state.activeChannels[member] == id
    }
    
    func isActive(using state: Transport.P2P.Store.State?) -> Bool {
        !isInactive(using: state)
    }
    
    func isInactive(using state: Transport.P2P.Store.State?) -> Bool {
        guard let state = state else {
            return false
        }
        
        return state.inactiveChannels.contains(id)
    }
}

private extension Matrix.ErrorResponse {
    
    func asForbidden() -> Forbidden? {
        switch self {
        case let .forbidden(content):
            return content
        default:
            return nil
        }
    }
}

private extension Dictionary where Key == HexString {
    
    subscript(key: [UInt8]) -> Value? {
        get { self[HexString(from: key)] }
        set { self[HexString(from: key)] = newValue }
    }
}
