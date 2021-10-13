//
//  P2PClient.swift
//
//
//  Created by Julia Samol on 16.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol P2PClient {
    
    // MARK: Connection
    
    func start(completion: @escaping (Result<(), Swift.Error>) -> ())
    func stop(completion: @escaping (Result<(), Swift.Error>) -> ())
    func pause(completion: @escaping (Result<(), Swift.Error>) -> ())
    func resume(completion: @escaping (Result<(), Swift.Error>) -> ())
    
    // MARK: Incoming Messages
    
    func listen(to peer: Beacon.P2PPeer, listener: @escaping (Result<String, Swift.Error>) -> ()) throws
    func removeListener(for peer: Beacon.P2PPeer) throws
    
    // MARK: Outgoing Messages
    
    func send(message: String, to peer: Beacon.P2PPeer, completion: @escaping (Result<(), Swift.Error>) -> ())
    func sendPairingResponse(to peer: Beacon.P2PPeer, completion: @escaping (Result<(), Swift.Error>) -> ())
}

public protocol P2PClientFactory {
    func create(with dependencyRegistry: DependencyRegistry) throws -> P2PClient
}
