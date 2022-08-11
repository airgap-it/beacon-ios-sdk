//
//  BlockchainTezosRequest.swift
//  
//
//  Created by Julia Samol on 28.09.21.
//

import Foundation
import BeaconCore

/// Tezos specific content of the `BeaconRequest.blockchain` message.
public enum BlockchainTezosRequest: BlockchainBeaconRequestProtocol, Equatable {
    
    ///
    /// Message requesting the broadcast of the given Tezos operations.
    ///
    /// The operations may be only partially filled by the dApp and lack certain information.
    /// Expects `BlockchainTezosResponse.operation` as a response.
    ///
    /// - operation: The body of the message.
    ///
    case operation(_ operation: OperationTezosRequest)
    
    ///
    /// Message requesting the signature of the given payload.
    ///
    /// Expects `BlockchainTezosResponse.signPayload` as a response.
    ///
    /// - signPayload: The body of the message.
    ///
    case signPayload(_ signPayload: SignPayloadTezosRequest)
    
    ///
    /// Message requesting the broadcast of the given transaction.
    ///
    /// Expects `BlockchainTezosResponse.broadcast` as a response.
    ///
    /// - broadcast: The body of the message.
    ///
    case broadcast(_ broadcast: BroadcastTezosRequest)
    
    // MARK: Attributes
    
    /// The value that identifies this request.
    public var id: String { common.id }
    
    /// The version of the message.
    public var version: String { common.version }
    
    /// The value that identifies the sender of this request.
    public var senderID: String { common.senderID }
    
    /// The origination data of this request.
    public var origin: Beacon.Connection.ID { common.origin }
    
    public var destination: Beacon.Connection.ID { common.destination }
    
    /// The account identifier of the account that is requested to handle this request. May be `nil`.
    public var accountID: String? { common.accountID }
    
    private var common: BlockchainBeaconRequestProtocol {
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
