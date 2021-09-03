//
//  Matrix.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class Matrix {
    private let store: Store
    private let nodeService: NodeService
    private let userService: UserService
    private let eventService: EventService
    private let roomService: RoomService
    private let timeUtils: TimeUtilsProtocol
    
    private let guardQueue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.Matrix.guard", attributes: [], target: .global(qos: .default))
    
    private var pollQueues: [String: DispatchQueue] = [:]
    private var cancelledQueues: Set<String> = []
    
    init(
        store: Store,
        nodeService: NodeService,
        userService: UserService,
        eventService: EventService,
        roomService: RoomService,
        timeUtils: TimeUtilsProtocol
    ) {
        self.store = store
        self.nodeService = nodeService
        self.userService = userService
        self.eventService = eventService
        self.roomService = roomService
        self.timeUtils = timeUtils
    }
    
    // MARK: State
    
    func joinedRooms(completion: @escaping (Result<[Room], Swift.Error>) -> ()) {
        store.state { state in
            completion(state.map { $0.rooms.values.filter { $0.status == .joined } })
        }
    }
    
    func invitedRooms(completion: @escaping (Result<[Room], Swift.Error>) -> ()) {
        store.state { state in
            completion(state.map { $0.rooms.values.filter { $0.status == .invited } })
        }
    }
    
    func leftRooms(completion: @escaping (Result<[Room], Swift.Error>) -> ()) {
        store.state { state in
            completion(state.map { $0.rooms.values.filter { $0.status == .left } })
        }
    }
    
    func subscribe(for kind: Event.Kind, with listener: EventListener) {
        let listener = Store.EventsListener(id: listener.id) { events in
            events
                .filter { $0.isOf(kind: kind) }
                .forEach { listener.notify(with: $0) }
        }
        
        store.add(eventsListener: listener)
    }
    
    func unsubscribe(_ listener: EventListener) {
        store.remove(listenerWithID: listener.id)
    }
    
    // MARK: Node
    
    func isUp(_ node: String, completion: @escaping (Result<Bool, Swift.Error>) -> ()) {
        nodeService.isUp(node, completion: completion)
    }
    
    // MARK: Sync
    
    func start(on node: String, userID: String, password: String, deviceID: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        userService.login(on: node, user: userID, password: password, deviceID: deviceID) { [weak self] result in
            guard let response = result.get(ifFailure: completion) else { return }
            
            guard let accessToken = response.accessToken else {
                completion(.failure(Error.login("Login was successful, but accessToken has not been provided.")))
                return
            }
            
            guard let selfStrong = self else {
                completion(.failure(Beacon.Error.unknown))
                return
            }
            
            selfStrong.store.intent(action: .initialize(userID: userID, deviceID: deviceID, accessToken: accessToken)) { result in
                guard result.isSuccess(else: completion) else { return }
                selfStrong.poll(on: node, completion: completion)
            }
        }
    }
    
    func stop(on node: String? = nil, completion: @escaping () -> () = {}) {
        guardQueue.async {
            if let node = node {
                self.cancelledQueues.insert(node)
            } else {
                self.cancelledQueues.formUnion(self.pollQueues.keys)
            }
            completion()
        }
    }
    
    func resetHard(on node: String? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        stop(on: node) {
            self.store.intent(action: .hardReset, completion: completion)
        }
    }
    
    func sync(on node: String, completion: @escaping (Result<Sync, Swift.Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            guard let accessToken = state.accessToken else {
                completion(.failure(Error.requiresAuthorization("sync")))
                return
            }
            
            self.eventService.sync(on: node, withToken: accessToken, since: state.syncToken, timeout: state.pollingTimeout) { result in
                completion(result.map { Sync(from: $0, node: node) })
            }
        }
    }
    
    private func poll(on node: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        poll(on: node) { [weak self] (result, callbackReturn) in
            guard let selfStrong = self else {
                completion(.failure(Beacon.Error.unknown))
                return
            }
            
            switch result {
            case let .success(response):
                selfStrong.store.state {
                    if let state = $0.get(ifFailure: completion), !state.isPolling {
                        completion(.success(()))
                    }
                
                    selfStrong.store.intent(
                        action: .onSyncSuccess(
                            syncToken: response.nextBatch,
                            pollingTimeout: 30000,
                            rooms: response.rooms,
                            events: response.events
                        )
                    ) { _ in callbackReturn() }
                }
            case let .failure(error):
                selfStrong.store.state {
                    if let state = $0.get(ifFailure: completion), !state.isPolling {
                        completion(.failure(error))
                    }
                    
                    selfStrong.store.intent(action: .onSyncFailure) { _ in callbackReturn() }
                }
            }
        }
    }
    
    private func poll(
        on node: String,
        every interval: DispatchTimeInterval = .milliseconds(0),
        onResult callback: @escaping (Result<Sync, Swift.Error>, @escaping () -> ()) -> ()
    ) {
        pollQueue(for: node) {
            $0.async {
                self.sync(on: node) { result in
                    callback(result) { [weak self] in
                        switch result {
                        case .success(_):
                            self?.schedule(on: node, after: interval) {
                                self?.poll(on: node, every: interval, onResult: callback)
                            }
                        case .failure(_):
                            self?.store.state { [weak self] in
                                guard let state = try? $0.get() else { return }
                                if state.pollingRetries < Beacon.Configuration.matrixMaxSyncRetries {
                                    self?.schedule(on: node, after: interval) {
                                        self?.poll(on: node, every: interval, onResult: callback)
                                    }
                                } /* else: max retries exceeded */
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func schedule(on node: String, after delay: DispatchTimeInterval, action: @escaping () -> ()) {
        pollQueue(for: node) {
            $0.asyncAfter(deadline: .now() + delay) {
                self.guardQueue.async {
                    guard !self.cancelledQueues.contains(node) else {
                        self.removePollQueue(for: node)
                        return
                    }
                    action()
                }
            }
        }
    }
    
    private func cancelScheduled(on node: String, completion: @escaping () -> ()) {
        guardQueue.async {
            self.cancelledQueues.insert(node)
            completion()
        }
    }
    
    private func pollQueue(for node: String, completion: @escaping (DispatchQueue) -> ()) {
        guardQueue.async {
            let queue = self.pollQueues.getOrSet(node) {
                .init(label: "it.airgap.beacon-sdk.Matrix.poll#\(node)", target: .global(qos: .default))
            }
            completion(queue)
        }
    }
    
    private func removePollQueue(for node: String, completion: @escaping () -> () = {}) {
        guardQueue.async {
            self.pollQueues.removeValue(forKey: node)
            if self.pollQueues.isEmpty {
                self.store.intent(action: .reset) { _ in completion() }
            } else {
                completion()
            }
        }
    }
    
    // MARK: Room Management
    
    func createTrustedPrivateRoom(on node: String, invitedMembers members: [String], completion: @escaping (Result<Room?, Swift.Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            guard let accessToken = state.accessToken else {
                completion(.failure(Error.requiresAuthorization("createTrustedPrivateRoom")))
                return
            }
            
            let roomRequest = RoomService.CreateRequest(
                invite: members,
                roomVersion: Beacon.Configuration.matrixClientRoomVersion,
                preset: .trustedPrivateChat,
                isDirect: true
            )
            self.roomService.createRoom(on: node, withToken: accessToken, configuredWith: roomRequest) { result in
                completion(result.map { $0.roomID.map { Matrix.Room(status: .unknown, id: $0) } })
            }
        }
    }
    
    func joinRoom(on node: String, roomID: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            guard let accessToken = state.accessToken else {
                completion(.failure(Error.requiresAuthorization("joinRoom")))
                return
            }
            
            self.roomService.joinRoom(on: node, withToken: accessToken, roomID: roomID) { result in
                completion(result.map({ _ in () }))
            }
        }
    }
    
    // MARK: Event Management
    
    func send(on node: String, message: String, to room: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            guard let accessToken = state.accessToken else {
                completion(.failure(Error.requiresAuthorization("send")))
                return
            }
            
            self.createTxnID { result in
                guard let txnID = result.get(ifFailure: completion) else { return }
                self.eventService.send(on: node, withToken: accessToken, textMessage: message, to: room, txnID: txnID) { result in
                    completion(result.map { _ in () })
                }
            }
        }
    }
    
    private func createTxnID(completion: @escaping (Result<String, Swift.Error>) -> ()) {
        store.state {
            guard let state = $0.get(ifFailure: completion) else { return }
            let timestamp = self.timeUtils.currentTimeMillis
            let counter = state.transactionCounter
            
            self.store.intent(action: .onTxnIDCreated) { result in
                completion(result.map { "m\(timestamp).\(counter)" })
            }
        }
    }
    
    // MARK: Types
    
    typealias EventListener = DistinguishableListener<Event>
    
    enum Error: Swift.Error {
        case login(String? = nil)
        case requiresAuthorization(String)
        case relevantRoomNotFound
    }
}
