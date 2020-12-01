//
//  Error.swift
//  BeaconSDK
//
//  Created by Julia Samol on 26.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public enum Error: Swift.Error {
        case uninitialized
        
        case invalidPublicKey(String, cause: Swift.Error? = nil)
        
        // MARK: Connection
        
        case connectionFailed([Connection.Kind], causedBy: [Swift.Error])
        
        case peersNotPaired([PeerInfo], causedBy: [Swift.Error])
        case peersNotConnected([PeerInfo], causedBy: [Swift.Error])
        case peersNotDisconnected([PeerInfo], causedBy: [Swift.Error])
        
        case sendFailed([Connection.Kind], causedBy: [Swift.Error])
        
        // MARK: Response
        
        case noPendingRequest(withID: String)
        case sendToPeersFailed([PeerInfo], causedBy: [Swift.Error])
        
        // MARK: P2P
        
        case emptyNodes
        
        // MARK: Other
        
        case other(Swift.Error)
        case unknown
        
        init(_ error: Swift.Error) {
            guard let beaconError = error as? Error else {
                self = .other(error)
                return
            }
            self = beaconError
        }
    }
}
