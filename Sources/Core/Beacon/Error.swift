//
//  Error.swift
//
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
        
        /// The requested blockchain was not registered.
        ///
        /// - identifier: The unique name of the blockchain.
        ///
        case blockchainNotFound(_ identifier: String)
        
        // MARK: Connection
        
        case missingPairedPeer
        
        ///
        /// Could not establish connections of the requested types.
        ///
        /// - kinds: Types of connections that failed.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case connectionFailed(_ kinds: [Connection.Kind], causedBy: [Swift.Error])
        
        ///
        /// Could not stop connections.
        ///
        /// - kinds: Types of connections that failed to stop.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case stopConnectionFailed(_ kinds: [Connection.Kind], causedBy: [Swift.Error])
        
        ///
        /// Could not pause connections.
        ///
        /// - kinds: Types of connections that failed to pause.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case pauseConnectionFailed(_ kinds: [Connection.Kind], causedBy: [Swift.Error])
        
        ///
        /// Could not resume connections.
        ///
        /// - kinds: Types of connections that failed to resume.
        /// - causedBy: An array of the initial causes of the error, if known.
        ///
        case resumeConnectionFailed(_ kinds: [Connection.Kind], causedBy: [Swift.Error])
        
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
        /// - version: Beacon version of the peer.
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
        /// The requested transport is not supported by the client.
        ///
        /// - kind: Type of requested connection.
        /// 
        case transportNotSupported(_ kind: Connection.Kind)
        
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
        /// - message: The message that could not be processed.
        /// - version: The target message version.
        ///
        case messageNotSupportedInVersion(message: BeaconMessageProtocol, version: String)
        
        ///
        /// The message version is not supported by the target blockchain.
        ///
        ///  - version: The message version that could not be processed.
        ///  - blockchainIdentifier: The target blockchain identifier.
        ///
        case messageVersionNotSupported(version: String, blockchainIdentifier: String)
        
        ///
        /// The message type is not recognized.
        ///
        /// - message: The message type that could not be processed.
        /// - version: The target message version.
        ///
        case unknownMessageType(_ messageType: String, version: String)
        
        ///
        /// The message is not valid in the given context.
        /// 
        case unknownBeaconMessage
        
        ///
        /// The message belongs to a different blockchain than expected.
        ///
        /// - blockchainIdentifier: The identifier of the unexpected blockchain.
        /// 
        case unexpectedBlockchainIdentifier(_ blockchainIdentifier: String)
        
        // MARK: Account
        
        ///
        /// The requested account does not exist in Beacon.
        ///
        /// - accountID: The account identifier.
        /// 
        case accountNotFound(_ accountID: String)
        
        case noActiveAccount

        case noAccountNetworkFound(_ accountID: String)
        
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
        
        ///
        /// Unknown type of error.
        ///
        /// - description: An optional description of the error.
        ///
        case unknown(_ description: String? = nil)
        
        public init(_ error: Swift.Error) {
            guard let beaconError = error as? Error else {
                self = .other(error)
                return
            }
            self = beaconError
        }
    }
}
