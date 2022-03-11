//
//  BlockchainSubstrateResponse.swift
//  
//
//  Created by Julia Samol on 10.01.22.
//

import Foundation
import BeaconCore

/// Substrate specific content of the `BeaconResponse.blockchain` message.
public enum BlockchainSubstrateResponse: BlockchainBeaconResponseProtocol, Equatable {

    ///
    /// Message responding to `BlockchainSubstrateRequest.transfer`.
    ///
    /// - transfer: The body of the message.
    ///
    case transfer(_ transfer: TransferSubstrateResponse)
    
    ///
    /// Message responding to `BlockchainSubstrateRequest.sign`.
    ///
    /// - sign: The body of the message.
    ///
    case signPayload(_ sign: SignPayloadSubstrateResponse)
    
    // MARK: Attributes
    
    /// The value that identifies the request to which the message is responding.
    public var id: String { common.id }
    
    /// The version of the message.
    public var version: String { common.version }
    
    /// The origination data of the request.
    public var requestOrigin: Beacon.Origin { common.requestOrigin }
    
    private var common: BlockchainBeaconResponseProtocol {
        switch self {
        case let .transfer(content):
            return content
        case let .signPayload(content):
            return content
        }
    }
}
