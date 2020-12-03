//
//  OperationRequest.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Request {
    
    /// Body of the `Beacon.Request.operation` message.
    public struct Operation: RequestProtocol, Equatable, Codable {
        
        /// The value that identifies this request.
        public let id: String
        
        /// The value that identifies the sender of this request.
        public let senderID: String
        
        /// The metadata describing the dApp asking for the broadcast. May be `nil` if the `senderID` is unknown.
        public let appMetadata: Beacon.AppMetadata?
        
        /// The network on which the operations should be broadcast.
        public let network: Beacon.Network
        
        /// Tezos operations which should be broadcast.
        public let operationDetails: [Tezos.Operation]
        
        /// The address of the Tezos account that is requested to broadcast the operations.
        public let sourceAddress: String
        
        /// The origination data of this request.
        public let origin: Beacon.Origin
    }
}
