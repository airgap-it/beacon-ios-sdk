//
//  P2PMatrix.swift
//  
//
//  Created by Julia Samol on 21.09.21.
//

import Foundation
import BeaconCore

public extension Transport.P2P {
    
    /// Beacon P2P implementation that uses [Matrix](https://matrix.org/) network for the communication.
    class Matrix: P2PClient {
        private let matrixClient: MatrixClient
        private let store: Store
        private let security: Security
        private let communicator: Communicator
        
        private var eventListeners: [HexString: MatrixClient.EventListener] = [:]
        private var internalListeners: [MatrixClient.EventListener] = []
        
        private let joinQueue: DispatchQueue = .init(
            label: "it.airgap.beacon-sdk.Transport.P2P.Matrix.join",
            attributes: [],
            target: .global(qos: .default)
        )
        
        init(
            matrixClient: MatrixClient,
            store: Store,
            security: Security,
            communicator: Communicator
        ) {
            self.matrixClient = matrixClient
            self.store = store
            self.security = security
            self.communicator = communicator
        }
        
        ///
        /// Creates a factory that should be used to dynamically register the client in Beacon.
        ///
        /// - Parameter storagePlugin: An optional external implementation of `P2PMatrixStoragePlugin`, if not provided an internal implementation will be used.
        /// - Parameter matrixNodes: A list of Matrix nodes used in the connection. One node will be selected randomly based on the local key pair and used as the primary connection node, the rest will be used as a fallback if the primary node goes down.
        /// - Parameter urlSession: An optional external `URLSession`.
        ///
        /// - Returns: A  `Transport.P2P.Matrix.Factory` instance.
        ///
        public static func factory(
            storagePlugin: P2PMatrixStoragePlugin?,
            matrixNodes: [String],
            urlSession: URLSession
        ) throws ->  Factory {
            try Factory(storagePlugin: storagePlugin, matrixNodes: matrixNodes, urlSession: urlSession)
        }
        
        ///
        /// Starts the connection.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Swift.Error` if it failed.
        ///
        public func start(completion: @escaping (_ result: Result<(), Swift.Error>) -> ()) {
            runCatching(completion: completion) {
                let userID = try security.userID()
                let deviceID = try security.deviceID()
                
                store.state {
                    guard let state = $0.get(ifFailure: completion) else { return }
                    
                    self.startRepeat(userID: userID, deviceID: deviceID, retrying: state.availableNodes) { result in
                        guard result.isSuccess(else: completion) else { return }
                    
                        let inviteListener = MatrixClient.EventListener { [weak self] event in
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
        
        ///
        /// Stops the connection.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Swift.Error` if it failed.
        ///
        public func stop(completion: @escaping (_ result: Result<(), Swift.Error>) -> ()) {
            self.matrixClient.stop { result in
                guard result.isSuccess(else: completion) else { return }
                
                self.matrixClient.unsubscribeAll()
                self.eventListeners.removeAll()
                self.internalListeners.removeAll()
                completion(.success(()))
            }
        }
        
        ///
        /// Pauses the connection.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Swift.Error` if it failed.
        ///
        public func pause(completion: @escaping (_ result: Result<(), Swift.Error>) -> ()) {
            self.matrixClient.pause(completion: completion)
        }
        
        ///
        /// Resumes the connection.
        ///
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Swift.Error` if it failed.
        ///
        public func resume(completion: @escaping (_ result: Result<(), Swift.Error>) -> ()) {
            self.matrixClient.resume(completion: completion)
        }
        
        private func startRepeat(
            userID: String,
            deviceID: String,
            retrying retry: Int,
            carrying carryError: Swift.Error? = nil,
            completion: @escaping (_ result: Result<(), Swift.Error>) -> ()
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
                    let password = try self.security.password()
                    
                    self.matrixClient.start(on: state.relayServer, userID: userID, password: password, deviceID: deviceID) { result in
                        guard let error = result.error else {
                            completion(.success(()))
                            return
                        }
                        
                        self.resetHard { result in
                            guard result.isSuccess(else: completion) else { return }
                            self.startRepeat(userID: userID, deviceID: deviceID, retrying: retry, carrying: error, completion: completion)
                        }
                    }
                }
            }
        }
        
        private func resetHard(completion: @escaping (_ result: Result<(), Swift.Error>) -> ()) {
            store.intent(action: .hardReset) { result in
                guard result.isSuccess(else: completion) else { return }
                self.matrixClient.resetHard(completion: completion)
            }
        }
        
        // MARK: Incoming Messages
        
        ///
        /// Listens for incoming messages.
        ///
        /// - Parameter peer: The peer which the client will observe.
        /// - Parameter listener: The closure called whenever a new message arrives.
        /// - Parameter result: A result representing the incoming message, either `String` or `Swift.Error` if message processing failed.
        ///
        public func listen(to peer: Beacon.P2PPeer, listener: @escaping (_ result: Result<String, Swift.Error>) -> ()) {
            guard let publicKey = try? HexString(from: peer.publicKey).asBytes() else { return }
            guard eventListeners[publicKey] == nil else { return }

            let textMessageListener = MatrixClient.EventListener { [weak self] event in
                guard let selfStrong = self else { return }
                selfStrong.store.state {
                    let state = try? $0.get()
                    if let relayServer = state?.relayServer, event.common.node != relayServer { return }
                    guard let textMessage = selfStrong.textMessage(from: event, sender: publicKey) else { return }
                    
                    selfStrong.store.intent(action: .onChannelEvent(sender: textMessage.sender, channelID: textMessage.roomID))
                    
                    listener(runCatching { try selfStrong.security.decrypt(message: textMessage, with: publicKey) })
                }
            }
            
            eventListeners[publicKey] = textMessageListener
            matrixClient.subscribe(for: .textMessage, with: textMessageListener)
        }
        
        ///
        /// Stops listening for messages coming from the specified peer.
        ///
        /// - Parameter peer: The peer that the client should stop observing.
        ///
        public func removeListener(for peer: Beacon.P2PPeer) {
            guard let publicKey = try? HexString(from: peer.publicKey) else { return }
            guard let listener = eventListeners.removeValue(forKey: publicKey) else { return }
            matrixClient.unsubscribe(listener)
        }
        
        private func textMessage(from event: MatrixClient.Event, sender publicKey: [UInt8]) -> MatrixClient.Event.TextMessage? {
            switch event {
            case let .textMessage(message):
                guard communicator.isMessage(message, from: publicKey) && communicator.isValidMessage(message) else {
                    return nil
                }
                
                return message
            default:
                return nil
            }
        }
        
        // MARK: Outgoing Messages
        
        ///
        /// Sends the message to the peer.
        ///
        /// - Parameter message: The message to send.
        /// - Parameter peer: The recipient of the message.
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Swift.Error` if it failed.
        ///
        public func send(message: String, to peer: Beacon.P2PPeer, completion: @escaping (_ result: Result<(), Swift.Error>) -> ()) {
            runCatching(completion: completion) {
                let publicKey = try HexString(from: peer.publicKey).asBytes()
                let recipient = try self.communicator.recipientIdentifier(for: publicKey, on: peer.relayServer)
                let encrypted = try self.security.encrypt(message: message, with: publicKey)
                
                self.matrixClient.send(
                    textMessage: HexString(from: encrypted).asString(),
                    to: recipient.asString(),
                    using: self.store,
                    completion: completion
                )
            }
        }
        
        ///
        /// Sends a pairing message to the peer.
        ///
        /// - Parameter peer: The recipient of the message.
        /// - Parameter completion: The closure called when the call completes.
        /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Swift.Error` if it failed.
        ///
        public func sendPairingResponse(
            to peer: Beacon.P2PPeer,
            completion: @escaping (_ result: Result<(), Swift.Error>) -> ()
        ) {
            store.state {
                guard let state = $0.get(ifFailure: completion) else { return }
                
                runCatching(completion: completion) {
                    let publicKey = try HexString(from: peer.publicKey).asBytes()
                    let recipient = try self.communicator.recipientIdentifier(for: publicKey, on: peer.relayServer)
                    let payload = try self.security.encryptPairingPayload(
                        try self.communicator.pairingPayload(for: peer, relayServer: state.relayServer),
                        with: publicKey
                    )
                    let message = self.communicator.channelOpeningMessage(
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
        
        private func invite(from event: MatrixClient.Event) -> MatrixClient.Event.Invite? {
            switch event {
            case let .invite(invite):
                return invite
            default:
                return nil
            }
        }
        
        private func acceptInviteRepeated(
            joining roomID: String,
            retrying retry: Int = Beacon.P2PMatrixConfiguration.p2pMaxJoinRetries,
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
                    
                    guard (error as? MatrixClient.ErrorResponse)?.asForbidden() != nil else {
                        completion(.failure(error))
                        return
                    }
                    
                    // Joining a room too quickly after receiving an invite event
                    // sometimes results in rejection from the server in a federated multi-node setup.
                    // Usually waiting a few milliseconds solves the issue.
                    
                    self.joinQueue.asyncAfter(deadline: .now() + .milliseconds(Beacon.P2PMatrixConfiguration.p2pJoinDelaysMs)) { [unowned self] in
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

public extension Transport.P2P.Matrix {
    
    ///
    /// Creates a connection that should be used to dynamically register the client in Beacon.
    ///
    /// - Parameter storagePlugin: An optional external implementation of `P2PMatrixStoragePlugin`, if not provided an internal implementation will be used.
    /// - Parameter matrixNodes: A list of Matrix nodes used in the connection, set to `Beacon.P2PMatrixConfiguration.defaultRelayServers` by default. One node will be selected randomly based on the local key pair and used as the primary connection node, the rest will be used as a fallback if the primary node goes down.
    /// - Parameter urlSession: An optional external `URLSession`.
    ///
    /// - Returns: A  `Beacon.Connection` instance.
    ///
    static func connection(
        storagePlugin: P2PMatrixStoragePlugin? = nil,
        matrixNodes: [String] = Beacon.P2PMatrixConfiguration.defaultRelayServers,
        urlSession: URLSession = .shared
    ) throws -> Beacon.Connection {
        .p2p(.init(client: try Transport.P2P.Matrix.factory(storagePlugin: storagePlugin, matrixNodes: matrixNodes, urlSession: urlSession)))
    }
}

private extension MatrixClient {
    
    func send(
        textMessage message: String,
        to recipient: String,
        using store: Transport.P2P.Matrix.Store,
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
                    
                    guard (error as? MatrixClient.ErrorResponse)?.asForbidden() != nil else {
                        completion(.failure(error))
                        return
                    }
                    
                    store.intent(action: .onChannelClosed(channelID: roomID)) { intentResult in
                        guard intentResult.isSuccess(else: completion) else { return }
                        
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
        using store: Transport.P2P.Matrix.Store,
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
        using store: Transport.P2P.Matrix.Store,
        completion: @escaping (Result<MatrixClient.Room?, Swift.Error>) -> ()
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
                        guard intentResult.isSuccess(else: completion) else { return }
                        completion(.success(room))
                    }
                }
            }
        }
    }
    
    private func waitForMember(
        _ member: String,
        joining room: Room,
        using store: Transport.P2P.Matrix.Store,
        completion: @escaping () -> ()
    ) {
        if room.members.contains(member) {
            completion()
            return
        }
    
        let joinEventListener = EventListener { [weak self] (listener, event) in
            switch event {
            case let .join(join):
                if join.roomID == room.id && join.userID == member {
                    self?.unsubscribe(listener)
                    completion()
                }
            default:
                break
            }
            
        }
        subscribe(for: .join, with: joinEventListener)
    }
}

private extension MatrixClient.Room {
    
    func isActive(forMember member: String, using state: Transport.P2P.Matrix.Store.State?) -> Bool {
        guard let state = state else {
            return false
        }
        
        return state.activeChannels[member] == id
    }
    
    func isActive(using state: Transport.P2P.Matrix.Store.State?) -> Bool {
        !isInactive(using: state)
    }
    
    func isInactive(using state: Transport.P2P.Matrix.Store.State?) -> Bool {
        guard let state = state else {
            return false
        }
        
        return state.inactiveChannels.contains(id)
    }
}

private extension MatrixClient.ErrorResponse {
    
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
