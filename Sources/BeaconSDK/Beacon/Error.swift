//
//  Error.swift
//  BeaconSDK
//
//  Created by Julia Samol on 26.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of error recognized in the Beacon SDK.
    public enum Error: Swift.Error {
        
        /// Beacon has not been initialized.
        case uninitialized
        
        ///
        /// An invalid public key string has been provided.
        ///
        /// - key: The invalid value.
        /// - causedBy: The initial cause of the error, if known.
        ///
        case invalidPublicKey(_ key: String, causedBy: Swift.Error? = nil)
        
        // MARK: Connection
        
        ///
        /// Could not establish connections of the requested types.
        ///
        /// - kinds: Types of connections that failed.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case connectionFailed(_ kinds: [Connection.Kind], causedBy: [Swift.Error])
        
        ///
        /// Could not pair with the peers.
        ///
        /// - peers: An array of peers that failed to be paired.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case peersNotPaired(_ peers: [Peer], causedBy: [Swift.Error])
        
        ///
        /// Could not connect with the peers.
        ///
        /// - peers: An array of peers which could not be connected.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case peersNotConnected(_ peers: [Peer], causedBy: [Swift.Error])
        
        ///
        /// Could not disconnect from the peers.
        ///
        /// - peers: An array of peers which could not be disconnected.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case peersNotDisconnected(_ peers: [Peer], causedBy: [Swift.Error])
        
        ///
        /// Invalid peer data for the specified Beacon version.
        ///
        /// - peer: The invalid data.
        /// - `version`: Beacon version of the peer.
        ///
        case invalidPeer(_ peer: Peer, version: String)
        
        ///
        /// Could not send the message.
        ///
        /// - kinds: Types of connections that failed to send the response.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case sendFailed(_ kinds: [Connection.Kind], causedBy: [Swift.Error])
        
        ///
        /// Relay server URL is invalid.
        ///
        /// - url: Invalid value.
        ///
        case invalidURL(_ url: String)
    
        // MARK: Message
        
        ///
        /// No pending request that matches the provided response has been found.
        ///
        /// - id: The ID of the response for which a pending request could not be found.
        ///
        case noPendingRequest(id: String)
        
        ///
        /// Could not send the response to peers.
        ///
        /// - peers: An array of peers to which the response could not be sent.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case sendToPeersFailed(_ peers: [Peer], causedBy: [Swift.Error])
        
        
        ///
        /// The message is not supported in the target Beacon version.
        ///
        /// - message: The message that could not be processed
        /// - `version`: The target message version
        ///
        case messageNotSupportedInVersion(message: Message, version: String)
        
        // MARK: P2P
        
        /// No P2P nodes have been configured.
        case emptyNodes
        
        // MARK: Other
        
        ///
        /// Internal type of error.
        ///
        /// - error: The error value.
        ///
        case other(_ error: Swift.Error)
        
        /// Unknown type of error.
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
