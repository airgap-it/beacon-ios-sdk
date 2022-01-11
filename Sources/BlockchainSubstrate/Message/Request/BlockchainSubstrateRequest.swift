//
//  BlockchainSubstrateRequest.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Substrate specific content of the `BeaconRequest.blockchain` message.
public enum BlockchainSubstrateRequest: BlockchainBeaconRequestProtocol, Equatable {
    
    ///
    /// Expects `BlockchainSubstrateResponse.transfer` as a response.
    ///
    /// - transfer: The body of the message.
    ///
    case transfer(_ transfer: TransferSubstrateRequest)
    
    ///
    /// Expects `BlockchainSubstrateResponse.sign` as a response.
    ///
    /// - sign: The body of the message.
    ///
    case sign(_ sign: SignSubstrateRequest)
    
    // MARK: Attributes
    
    /// The value that identifies this request.
    public var id: String { common.id }
    
    /// The version of the message.
    public var version: String { common.version }
    
    /// The unique name of the blockchain that specifies the request.
    public var blockchainIdentifier: String { common.blockchainIdentifier }
    
    /// The value that identifies the sender of this request.
    public var senderID: String { common.senderID }
    
    /// The origination data of this request.
    public var origin: Beacon.Origin { common.origin }
    
    /// The account identifier of the account that is requested to handle this request. May be `nil`.
    public var accountID: String? { common.accountID }
    
    private var common: BlockchainBeaconRequestProtocol {
        switch self {
        case let .transfer(content):
            return content
        case let .sign(content):
            return content
        }
    }
}
