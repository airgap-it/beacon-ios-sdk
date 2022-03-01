//
//  MatrixClient.swift
//  BeaconSDK
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore

public class MatrixClient {
    private let store: Store
    
    private let nodeService: NodeService
    private let userService: UserService
    private let eventService: EventService
    private let roomService: RoomService
    
    private var services: [MatrixService] {
        [nodeService, userService, eventService, roomService]
    }
    
    private let time: TimeProtocol
    
    private let guardQueue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.MatrixClient.guard", attributes: [], target: .global(qos: .default))
    private var pollers: [String: Poller<Sync>] = [:]
    
    init(
        store: Store,
        nodeService: NodeService,
        userService: UserService,
        eventService: EventService,
        roomService: RoomService,
        time: TimeProtocol
    ) {
        self.store = store
        self.nodeService = nodeService
        self.userService = userService
        self.eventService = eventService
        self.roomService = roomService
        self.time = time
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
    
    func unsubscribeAll() {
        store.removeAllListeners()
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
    
    func stop(on node: String? = nil, completion: @escaping (Result<(), Swift.Error>) -> () = { _ in }) {
        guardQueue.async {
            let nodes: [String] = {
                if let node = node {
                    return [node]
                } else {
                    return Array(self.pollers.keys)
                }
            }()
            
            nodes.forEach {
                self.pollers[$0]?.cancel()
                self.pollers.removeValue(forKey: $0)
            }
            
            self.services.forEach { $0.cancelAll() }
            self.store.intent(action: .stop(nodes: nodes), completion: completion)
        }
    }
    
    func pause(on node: String? = nil, completion: @escaping (Result<(), Swift.Error>) -> () = { _ in }) {
        guardQueue.async {
            let nodes: [String] = {
                if let node = node {
                    return [node]
                } else {
                    return Array(self.pollers.keys)
                }
            }()
            
            nodes.forEach {
                self.pollers[$0]?.suspend()
            }
            
            self.services.forEach { $0.suspendAll() }
            self.store.intent(action: .stop(nodes: nodes), completion: completion)
        }
    }
    
    func resume(on node: String? = nil, completion: @escaping (Result<(), Swift.Error>) -> () = { _ in }) {
        guardQueue.async {
            let nodes: [String] = {
                if let node = node {
                    return [node]
                } else {
                    return Array(self.pollers.keys)
                }
            }()
            
            nodes.forEach {
                self.pollers[$0]?.resume()
            }
            
            self.services.forEach { $0.resumeAll() }
            self.store.intent(action: .resume(nodes: nodes), completion: completion)
        }
    }
    
    func resetHard(on node: String? = nil, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        stop(on: node) { result in
            guard result.isSuccess(else: completion) else { return }
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
        var _completion: ((Result<(), Swift.Error>) -> ())? = completion
        let disposableCompletion: (Result<(), Swift.Error>) -> () = {
            _completion?($0)
            _completion = nil
        }
        
        poll(on: node) { [weak self] result, continuation in
            guard let selfStrong = self else {
                disposableCompletion(.success(()))
                return
            }
            
            switch result {
            case let .success(response):
                selfStrong.store.state {
                    if let state = $0.get(ifFailure: disposableCompletion), !state.isPolling.get(node, orDefault: false) {
                        disposableCompletion(.success(()))
                    }
                
                    selfStrong.store.intent(
                        action: .onSyncSuccess(
                            node: node,
                            syncToken: response.nextBatch,
                            pollingTimeout: 30000,
                            rooms: response.rooms,
                            events: response.events
                        )
                    ) { _ in continuation() }
                }
            case let .failure(error):
                selfStrong.store.state {
                    if let state = $0.get(ifFailure: disposableCompletion), !state.isPolling.get(node, orDefault: false) {
                        disposableCompletion(.failure(error))
                    }
                    
                    selfStrong.store.intent(action: .onSyncFailure(node: node)) { _ in continuation() }
                }
            }
        }
    }
    
    private func poll(
        on node: String,
        every interval: DispatchTimeInterval = .milliseconds(0),
        onResult callback: @escaping (Result<Sync, Swift.Error>, @escaping () -> ()) -> ()
    ) {
        poller(for: node) {
            $0.run(every: interval) { result, continuation in
                callback(result) { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    switch result {
                    case .success(_):
                        continuation(.success(()))
                    case let .failure(error):
                        strongSelf.store.state {
                            guard let state = try? $0.get(), state.pollingRetries.get(node, orDefault: 0) < Beacon.P2PMatrixConfiguration.matrixMaxSyncRetries else {
                                /* max retries exceeded */
                                continuation(.failure(error))
                                return
                            }
                            
                            continuation(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    private func poller(for node: String, completion: @escaping (Poller<Sync>) -> ()) {
        guardQueue.async {
            let queue = self.pollers.get(node) {
                .init { [weak self] in self?.sync(on: node, completion: $0) }
            }
            completion(queue)
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
                roomVersion: Beacon.P2PMatrixConfiguration.matrixClientRoomVersion,
                preset: .trustedPrivateChat,
                isDirect: true
            )
            self.roomService.createRoom(on: node, withToken: accessToken, configuredWith: roomRequest) { result in
                completion(result.map { $0.roomID.map { MatrixClient.Room(status: .unknown, id: $0) } })
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
            let timestamp = self.time.currentTimeMillis
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
