//
//  SignSubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Body of the `BlockchainSubstrateRequest.sign` message.
public struct SignSubstrateRequest: BlockchainBeaconRequestProtocol, Identifiable, Equatable, Codable {
    
    /// The value that identifies this request.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The origination data of this request.
    public let origin: Beacon.Origin
    
    /// The account identifier of the account that is requested to handle this request.
    public let accountID: String?
    
    public let scope: Substrate.Permission.Scope
    
    public let network: Substrate.Network
    
    public let runtimeSpec: Substrate.RuntimeSpec
    
    public let payload: String
    
    public let mode: Mode
    
    // MARK: Mode
    
    public enum Mode: String, Codable, Equatable {
        case broadcast
        case broadcastAndReturn = "broadcast_and_return"
        case `return`
    }
}
