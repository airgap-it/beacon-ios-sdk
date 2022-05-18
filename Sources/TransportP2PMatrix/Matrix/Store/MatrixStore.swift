//
//  MatrixStore.swift
//  BeaconSDK
//
//  Created by Julia Samol on 17.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore

extension MatrixClient {
    
    class Store: StoreBox<Store.Associated> {
        
        init(storageManager: StorageManager) {
            super.init(store: .init(storageManager: storageManager))
        }
        
        func add(eventsListener listener: EventsListener) {
            associated.add(eventsListener: listener)
        }
        
        func remove(eventsListener listener: EventsListener) {
            associated.remove(eventsListener: listener)
        }
        
        func remove(listenerWithID listenerID: String) {
            associated.remove(listenerWithID: listenerID)
        }
        
        func removeAllListeners() {
            associated.removeAllListeners()
        }
        
        // MARK: Associated
        
        class Associated: StoreProtocol {
            typealias State = Store.State
            typealias Action = Store.Action
            
            private var state: State = State()
            
            @Disposable private var initialEvents: [Event]?
            private var eventsListeners: Set<EventsListener> = []
            
            private let storageManager: StorageManager
            
            init(storageManager: StorageManager) {
                self.storageManager = storageManager
            }
            
            // MARK: State
            
            func state(completion: @escaping (Result<State, Swift.Error>) -> ()) {
                completion(.success(state))
            }
            
            func intent(action: Action, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                switch action {
                case let .initialize(userID, deviceID, accessToken):
                    initialize(userID: userID, deviceID: deviceID, accessToken: accessToken, completion: completion)
                case let .stop(nodes: nodes):
                    stop(nodes: nodes, completion: completion)
                case let .resume(nodes: nodes):
                    resume(nodes: nodes, completion: completion)
                case let .onSyncSuccess(node, syncToken, pollingTimeout, rooms, events):
                    onSyncSuccess(
                        node: node,
                        syncToken: syncToken,
                        pollingTimeout: pollingTimeout,
                        rooms: rooms,
                        events: events,
                        completion: completion
                    )
                case let .onSyncFailure(node):
                    onSyncFailure(node: node, completion: completion)
                case .onTxnIDCreated:
                    onTxnIDCreated(completion: completion)
                case .hardReset:
                    resetHard(completion: completion)
                }
            }
            
            // MARK: Event Subscription
            
            func add(eventsListener listener: EventsListener) {
                if eventsListeners.isEmpty, let initialEvents = initialEvents {
                    listener.notify(with: initialEvents)
                }
                
                eventsListeners.insert(listener)
            }
            
            func remove(eventsListener listener: EventsListener) {
                eventsListeners.remove(listener)
            }
            
            func remove(listenerWithID listenerID: String) {
                guard let listener = eventsListeners.first(where: { $0.id == listenerID }) else { return }
                eventsListeners.remove(listener)
            }
            
            func removeAllListeners() {
                eventsListeners.removeAll()
            }
            
            private func notify(with events: [Event]) {
                guard !events.isEmpty else {
                    return
                }
                
                if eventsListeners.isEmpty {
                    initialEvents = events
                }
                
                eventsListeners.forEach { $0.notify(with: events) }
            }
            
            // MARK: Action Handlers
            
            private func initialize(userID: String?, deviceID: String?, accessToken: String?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                storageManager.getMatrixSyncToken { result in
                    guard let token = result.get(ifFailure: completion) else { return }

                    self.storageManager.getMatrixRooms { result in
                        guard let rooms = result.get(ifFailure: completion) else { return }
                        self.state = State(
                            from: self.state,
                            userID: userID,
                            deviceID: deviceID,
                            accessToken: accessToken,
                            syncToken: token,
                            rooms: rooms.toDictionary()
                        )

                        completion(.success(()))
                    }
                }
            }
            
            private func stop(nodes: [String], completion: @escaping (Result<(), Swift.Error>) -> ()) {
                state = State(
                    from: self.state,
                    isPolling: state.isPolling.merging(nodes.map({ ($0, false) }), uniquingKeysWith: { lhs, rhs in rhs })
                )
                completion(.success(()))
            }
            
            private func resume(nodes: [String], completion: @escaping (Result<(), Swift.Error>) -> ()) {
                state = State(
                    from: self.state,
                    isPolling: state.isPolling.merging(nodes.map({ ($0, true) }), uniquingKeysWith: { lhs, rhs in rhs })
                )
                completion(.success(()))
            }
            
            private func onSyncSuccess(
                node: String,
                syncToken: String?,
                pollingTimeout: Int64,
                rooms: [Room]?,
                events: [Event]?,
                completion: @escaping (Result<(), Swift.Error>) -> ()
            ) {
                let mergedRooms = rooms.map { state.rooms.merged(with: $0) }
                if let events = events {
                    notify(with: events)
                }
                
                updateStorage(syncToken: syncToken, rooms: mergedRooms) { result in
                    guard result.isSuccess(else: completion) else { return }
               
                    self.state = State(
                        from: self.state,
                        isPolling: self.state.isPolling.merging([node: true], uniquingKeysWith: { lhs, rhs in rhs }),
                        syncToken: .some(syncToken),
                        pollingTimeout: pollingTimeout,
                        pollingRetries: self.state.pollingRetries.merging([node: 0], uniquingKeysWith: { lhs, rhs in rhs }),
                        rooms: mergedRooms ?? self.state.rooms
                    )
                    
                    completion(.success(()))
                }
            }
            
            private func onSyncFailure(node: String, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                state = State(
                    from: state,
                    isPolling: state.isPolling.merging([node: false], uniquingKeysWith: { lhs, rhs in rhs }),
                    pollingRetries: state.pollingRetries.merging(
                        [node: state.pollingRetries[node, default: 0]],
                        uniquingKeysWith: { lhs, rhs in rhs }
                    )
                )
                completion(.success(()))
            }
            
            private func onTxnIDCreated(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                state = State(from: state, transactionCounter: state.transactionCounter + 1)
                completion(.success(()))
            }
            
            private func resetHard(completion: @escaping (Result<(), Swift.Error>) -> ()) {
                storageManager.removeMatrixRooms { result in
                    guard result.isSuccess(else: completion) else { return }

                    self.eventsListeners.removeAll()
                    self.state = State(syncToken: self.state.syncToken)
                    completion(.success(()))
                }
            }
            
            private func updateStorage(syncToken: String?, rooms: [String: Room]?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
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
            
            private func updateStorage(with rooms: [String: Room]?, completion: @escaping (Result<(), Swift.Error>) -> ()) {
                if let rooms = rooms?.values {
                    storageManager.set(Array(rooms), completion: completion)
                } else {
                    completion(.success(()))
                }
            }
        }
        
        // MARK: Types
        
        typealias EventsListener = DistinguishableListener<[Event]>
    }
}

// MARK: Extensions

private extension Dictionary where Key == String, Value == MatrixClient.Room {
    
    func merged(with newRooms: [MatrixClient.Room]) -> [Key: Value] {
        guard !newRooms.isEmpty else {
            return self
        }
        
        let newValues = newRooms.map { room in self[room.id]?.update(withMembers: room.members) ?? room }
        
        return (values + newValues).toDictionary()
    }
}

private extension Array where Element == MatrixClient.Room {
    
    func toDictionary() -> [String: Element] {
        grouped(by: { $0.id })
    }
}
