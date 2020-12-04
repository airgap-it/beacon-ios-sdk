//
//  Store.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Matrix {
    
    class Store {
        private var isInitialized: Bool = false
        
        private var state: State = State()
        private let queue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.Matrix.Store", attributes: [], target: .global(qos: .default))
        
        private var eventsListeners: Set<EventsListener> = Set()
        
        private let storageManager: StorageManager
        
        init(storageManager: StorageManager) {
            self.storageManager = storageManager
        }
        
        // MARK: Initialization
        
        private func whenReady(onReady callback: @escaping (Result<(), Swift.Error>) -> ()) {
            storageManager.getMatrixSyncToken { result in
                guard let token = result.get(ifFailure: callback) else { return }
                
                self.storageManager.getMatrixRooms { result in
                    guard let rooms = result.get(ifFailure: callback) else { return }
                    
                    self.state = State(
                        from: self.state,
                        syncToken: token,
                        rooms: self.state.rooms.merged(with: rooms)
                    )
                    self.isInitialized = true
                    
                    callback(.success(()))
                }
            }
        }
        
        // MARK: State
        
        func state(completion: @escaping (Result<State, Swift.Error>) -> ()) {
            whenReady { result in
                guard result.isSuccess(else: completion) else { return }
                self.queue.async {
                    completion(.success(self.state))
                }
            }
        }
        
        func intent(action: Action, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            whenReady { result in
                guard result.isSuccess(else: completion) else { return }
                
                switch action {
                case let .initialize(userID, deviceID, accessToken):
                    self.initialize(userID: userID, deviceID: deviceID, accessToken: accessToken, completion: completion)
                case let .onSyncSuccess(syncToken, pollingTimeout, rooms, events):
                    self.onSyncSuccess(
                        syncToken: syncToken,
                        pollingTimeout: pollingTimeout,
                        rooms: rooms,
                        events: events,
                        completion: completion
                    )
                case .onSyncFailure:
                    self.onSyncFailure(completion: completion)
                case .onTxnIDCreated:
                    self.onTxnIDCreated(completion: completion)
                }
            }
        }
        
        // MARK: Event Subscription
        
        func add(eventsListener listener: EventsListener) {
            eventsListeners.insert(listener)
        }
        
        func remove(eventsListener listener: EventsListener) {
            eventsListeners.remove(listener)
        }
        
        func remove(listenerWithID listenerID: String) {
            guard let listener = eventsListeners.first(where: { $0.id == listenerID }) else { return }
            eventsListeners.remove(listener)
        }
        
        private func notify(with events: [Matrix.Event]) {
            guard !events.isEmpty else {
                return
            }
            
            eventsListeners.forEach { $0.notify(with: events) }
        }
        
        // MARK: Action Handlers
        
        private func initialize(userID: String?, deviceID: String?, accessToken: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            queue.async {
                self.state = State(from: self.state, userID: userID, deviceID: deviceID, accessToken: accessToken)
                completion(.success(()))
            }
        }
        
        private func onSyncSuccess(
            syncToken: String?,
            pollingTimeout: Int64,
            rooms: [Matrix.Room]?,
            events: [Matrix.Event]?,
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            let mergedRooms = rooms.map { state.rooms.merged(with: $0) }
            if let events = events {
                notify(with: events)
            }
            
            updateStorage(syncToken: syncToken, rooms: mergedRooms) { result in
                guard result.isSuccess(else: completion) else { return }
           
                self.queue.async {
                    self.state = State(
                        from: self.state,
                        isPolling: true,
                        syncToken: .some(syncToken),
                        pollingTimeout: pollingTimeout,
                        pollingRetries: 0,
                        rooms: mergedRooms ?? self.state.rooms
                    )
                    
                    completion(.success(()))
                }
            }
        }
        
        private func onSyncFailure(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            queue.async {
                self.state = State(from: self.state, isPolling: false, pollingRetries: self.state.pollingRetries + 1)
                completion(.success(()))
            }
        }
        
        private func onTxnIDCreated(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            queue.async {
                self.state = State(from: self.state, transactionCounter: self.state.transactionCounter + 1)
                completion(.success(()))
            }
        }
        
        private func updateStorage(syncToken: String?, rooms: [String: Matrix.Room]?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            updateStorage(with: syncToken) { result in
                guard result.isSuccess(else: completion) else { return }
                self.updateStorage(with: rooms, completion: completion)
            }
        }
        
        private func updateStorage(with syncToken: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            if let syncToken = syncToken {
                storageManager.setMatrixSyncToken(syncToken, completion: completion)
            } else {
                completion(.success(()))
            }
        }
        
        private func updateStorage(with rooms: [String: Matrix.Room]?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            if let rooms = rooms?.values {
                storageManager.set(Array(rooms), completion: completion)
            } else {
                completion(.success(()))
            }
        }
        
        // MARK: Types
        
        typealias EventsListener = DistinguishableListener<[Matrix.Event]>
    }
}

// MARK: Extensions

private extension Dictionary where Key == String, Value == Matrix.Room {
    
    func merged(with newRooms: [Matrix.Room]) -> [Key: Value] {
        guard !newRooms.isEmpty else {
            return self
        }
        
        let newValues = newRooms.map { room in self[room.id]?.update(withMembers: room.members) ?? room }
        let updatedEntries = (values + newValues).map { ($0.id, $0) }
        
        return Dictionary(updatedEntries, uniquingKeysWith: { _, last in last })
    }
}
