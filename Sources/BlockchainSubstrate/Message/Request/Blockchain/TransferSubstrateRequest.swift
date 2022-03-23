//
//  TransferSubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Body of the `BlockchainSubstrateRequest.transfer` message.
public struct TransferSubstrateRequest: BlockchainBeaconRequestProtocol, Identifiable, Equatable, Codable {
    
    public var scope: Substrate.Permission.Scope { .transfer }
    
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
    
    public let sourceAddress: String
    
    public let amount: String
    
    public let recipient: String
    
    public let network: Substrate.Network
    
    public let mode: Mode
    
    // MARK: Mode
    
    public enum Mode: String, Codable, Equatable {
        case submit
        case submitAndReturn = "submit_and_return"
        case `return`
    }
}
