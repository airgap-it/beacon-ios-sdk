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
        private var eventsListeners: Set<EventsListener> = Set()
        
        private let storage: ExtendedStorage
        
        init(storage: ExtendedStorage) {
            self.storage = storage
        }
        
        // MARK: Initialization
        
        private func whenReady(onReady callback: @escaping (Result<(), Swift.Error>) -> ()) {
            storage.getMatrixSyncToken { [weak self] result in
                guard let token = result.get(ifFailure: callback) else { return }
                guard let selfStrong = self else {
                    callback(.failure(Error.unknown))
                    return
                }
                
                selfStrong.storage.getMatrixRooms { [weak self] result in
                    guard let rooms = result.get(ifFailure: callback) else { return }
                    guard let selfStrong = self else {
                        callback(.failure(Error.unknown))
                        return
                    }
                    
                    selfStrong.state = State(
                        from: selfStrong.state,
                        syncToken: token,
                        rooms: selfStrong.state.rooms.merge(with: rooms)
                    )
                    selfStrong.isInitialized = true
                    
                    callback(.success(()))
                }
            }
        }
        
        // MARK: State
        
        func state(completion: @escaping (Result<State, Swift.Error>) -> ()) {
            whenReady { [weak self] result in
                completion(result.map { self?.state ?? State() })
            }
        }
        
        func intent(action: Action, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            whenReady { [weak self] result in
                guard result.isSuccess(otherwise: completion) else { return }

                guard let selfStrong = self else {
                    completion(.failure(Error.unknown))
                    return
                }
                
                switch action {
                case let .initialize(userID, deviceID, accessToken):
                    selfStrong.initialize(userID: userID, deviceID: deviceID, accessToken: accessToken, completion: completion)
                case let .onSyncSuccess(syncToken, pollingTimeout, rooms, events):
                    selfStrong.onSyncSuccess(
                        syncToken: syncToken,
                        pollingTimeout: pollingTimeout,
                        rooms: rooms,
                        events: events,
                        completion: completion
                    )
                case .onSyncFailure:
                    selfStrong.onSyncFailure(completion: completion)
                case .onTxnIDCreated:
                    selfStrong.onTxnIDCreated(completion: completion)
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
        
        private func notify(with events: [Matrix.Event]) {
            guard !events.isEmpty else {
                return
            }
            
            eventsListeners.forEach { $0.on(value: events) }
        }
        
        // MARK: Action Handlers
        
        private func initialize(userID: String?, deviceID: String?, accessToken: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            state = State(from: state, userID: userID, deviceID: deviceID, accessToken: accessToken)
            completion(.success(()))
        }
        
        private func onSyncSuccess(
            syncToken: String?,
            pollingTimeout: Int64,
            rooms: [Matrix.Room]?,
            events: [Matrix.Event]?,
            completion: @escaping (Result<(), Swift.Error>) -> ()
        ) {
            let mergedRooms = rooms.map { state.rooms.merge(with: $0) }
            if let events = events {
                notify(with: events)
            }
            
            updateStorage(syncToken: syncToken, rooms: mergedRooms) { [weak self] result in
                guard result.isSuccess(otherwise: completion) else { return }
                
                guard let selfStrong = self else {
                    completion(.failure(Error.unknown))
                    return
                }
                
                selfStrong.state = State(
                    from: selfStrong.state,
                    isPolling: true,
                    syncToken: .some(syncToken),
                    pollingTimeout: pollingTimeout,
                    pollingRetries: 0,
                    rooms: mergedRooms ?? selfStrong.state.rooms
                )
                
                completion(.success(()))
            }
        }
        
        private func onSyncFailure(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            state = State(from: state, isPolling: false, pollingRetries: state.pollingRetries + 1)
            completion(.success(()))
        }
        
        private func onTxnIDCreated(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            state = State(from: state, transactionCounter: state.transactionCounter + 1)
            completion(.success(()))
        }
        
        private func updateStorage(syncToken: String?, rooms: [String: Matrix.Room]?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            updateStorage(with: syncToken) { result in
                guard result.isSuccess(otherwise: completion) else { return }
                self.updateStorage(with: rooms, completion: completion)
            }
        }
        
        private func updateStorage(with syncToken: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            if let syncToken = syncToken {
                storage.setMatrixSyncToken(syncToken, completion: completion)
            } else {
                completion(.success(()))
            }
        }
        
        private func updateStorage(with rooms: [String: Matrix.Room]?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            if let rooms = rooms?.values {
                storage.set(Array(rooms), completion: completion)
            } else {
                completion(.success(()))
            }
        }
        
        // MARK: Types
        
        typealias EventsListener = DistinguishableListener<[Matrix.Event]>
        
        enum Error: Swift.Error {
            case unknown
        }
    }
}

// MARK: Extensions

extension Dictionary where Key == String, Value == Matrix.Room {
    
    func merge(with newRooms: [Matrix.Room]) -> [Key: Value] {
        guard !newRooms.isEmpty else {
            return self
        }
        
        let newValues = newRooms.map { room in self[room.id]?.update(withMembers: room.members) ?? room }
        let updatedEntries = (values + newValues).map { ($0.id, $0) }
        
        return Dictionary(updatedEntries, uniquingKeysWith: { _, last in last })
    }
}
