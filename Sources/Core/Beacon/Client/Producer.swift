//
//  Producer.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public protocol BeaconProducer {
    func senderID() throws -> String
    
    func request<B: Blockchain>(with request: BeaconRequest<B>, completion: @escaping (_ result: Result<(), Beacon.Error>) -> ())
    func pair(using connectionKind: Beacon.Connection.Kind, onMessage listener: @escaping (_ result: Result<BeaconPairingMessage, Beacon.Error>) -> ())
    
    func prepareRequest(for connectionKind: Beacon.Connection.Kind, completion: @escaping (_ result: Result<BeaconRequestMetadata, Beacon.Error>) -> ())
}

public struct BeaconRequestMetadata {
    public let id: String
    public let version: String
    public let senderID: String
    public let origin: Beacon.Connection.ID
    public let destination: Beacon.Connection.ID
    public let account: Account?
    
    public init(
        id: String,
        version: String,
        senderID: String,
        origin: Beacon.Connection.ID,
        destination: Beacon.Connection.ID,
        account: Account?
    ) {
        self.id = id
        self.version = version
        self.senderID = senderID
        self.origin = origin
        self.destination = destination
        self.account = account
    }
}
