//
//  SignPayloadSubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Body of the `BlockchainSubstrateRequest.sign` message.
public struct SignPayloadSubstrateRequest: BlockchainBeaconRequestProtocol, Identifiable, Equatable, Codable {
    
    public var scope: Substrate.Permission.Scope {
        switch payload {
        case .json(_):
            return .signPayloadJSON
        case .raw(_):
            return .signPayloadRaw
        }
    }
    
    /// The value that identifies this request.
    public let id: String
    
    /// The version of the message.
    public let version: String
    
    /// The value that identifies the sender of this request.
    public let senderID: String
    
    /// The origination data of this request.
    public let origin: Beacon.Connection.ID
    
    /// The destination data of this request.
    public let destination: Beacon.Connection.ID
    
    /// The account identifier of the account that is requested to handle this request.
    public let accountID: String?
    
    public let address: String
    
    public let payload: Substrate.SignerPayload
    
    public let mode: Mode
    
    // MARK: Mode
    
    public enum Mode: String, Codable, Equatable {
        case submit
        case submitAndReturn = "submit_and_return"
        case `return`
    }
}
