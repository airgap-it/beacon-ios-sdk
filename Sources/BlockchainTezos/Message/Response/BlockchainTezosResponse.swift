//
//  BlockchainTezosResponse.swift
//  
//
//  Created by Julia Samol on 28.09.21.
//

import Foundation
import BeaconCore
    
/// Tezos specific content of the `BeaconResponse.blockchain` message.
public enum BlockchainTezosResponse: BlockchainBeaconResponseProtocol, Equatable {
    
    ///
    /// Message responding to `BlockchainTezosRequest.operation`.
    ///
    /// - operation: The body of the message.
    ///
    case operation(_ operation: OperationTezosResponse)
    
    ///
    /// Message responding to `BlockchainTezosRequest.signPayload`.
    ///
    /// - signPayload: The body of the message.
    ///
    case signPayload(_ signPayload: SignPayloadTezosResponse)
    
    ///
    /// Message responding to `BlockchainTezosRequest.broadcast`.
    ///
    /// - broadcast: The body of the message.
    ///
    case broadcast(_ broadcast: BroadcastTezosResponse)

    // MARK: Attributes
    
    /// The value that identifies the request to which the message is responding.
    public var id: String { common.id }
    
    /// The version of the message.
    public var version: String { common.version }
    
    /// The origination data of the request.
    public var destination: Beacon.Connection.ID { common.destination }
            
    private var common: BlockchainBeaconResponseProtocol {
        switch self {
        case let .operation(content):
            return content
        case let .signPayload(content):
            return content
        case let .broadcast(content):
            return content
        }
    }
}
