//
//  BroadcastRequest.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Request {
    
    /// Body of the `Beacon.Request.broadcast` message.
    public struct Broadcast: RequestProtocol, Equatable, Codable {
        
        /// The value that identifies this request.
        public let id: String
        
        /// The value that identifies the sender of this request.
        public let senderID: String
        
        /// The metadata describing the dApp asking for the broadcast. May be `nil` if the `senderID`is unknown.
        public let appMetadata: Beacon.AppMetadata?
        
        /// The network on which the transaction should be broadcast.
        public let network: Beacon.Network
        
        /// The transaction to be broadcast.
        public let signedTransaction: String
        
        /// The origination data of this request.
        public let origin: Beacon.Origin
        
        let version: String
        
        init(
            id: String,
            senderID: String,
            appMetadata: Beacon.AppMetadata?,
            network: Beacon.Network,
            signedTransaction: String,
            origin: Beacon.Origin,
            version: String
        ) {
            self.id = id
            self.senderID = senderID
            self.appMetadata = appMetadata
            self.network = network
            self.signedTransaction = signedTransaction
            self.origin = origin
            self.version = version
        }
    }
}
