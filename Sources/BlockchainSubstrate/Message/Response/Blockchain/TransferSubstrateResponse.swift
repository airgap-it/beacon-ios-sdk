//
//  TransferSubstrateResponse.swift
//  
//
//  Created by Julia Samol on 11.01.22.
//

import Foundation
import BeaconCore

public enum TransferSubstrateResponse: BlockchainBeaconResponseProtocol, Equatable {
    case submit(_ submit: SubmitTransferSubstrateResponse)
    case submitAndReturn(_ submitAndReturn: SubmitAndReturnTransferSubstrateResponse)
    case `return`(_ return: ReturnTransferSubstrateResponse)
    
    public init(from request: TransferSubstrateRequest, transactionHash: String?, signature: String?, payload: String?) throws {
        switch request.mode {
        case .submit:
            guard let transactionHash = transactionHash, signature == nil, payload == nil else {
                throw Error.invalidResponseMode
            }

            self = .submit(try .init(from: request, transactionHash: transactionHash))
        case .submitAndReturn:
            guard let transactionHash = transactionHash, let signature = signature else {
                throw Error.invalidResponseMode
            }

            self = .submitAndReturn(try .init(from: request, transactionHash: transactionHash, signature: signature, payload: payload))
        case .return:
            guard let signature = signature else {
                throw Error.invalidResponseMode
            }

            self = .return(try .init(from: request, signature: signature, payload: payload))
        }
    }
    
    // MARK: Attributes
    
    /// The value that identifies the request to which the message is responding.
    public var id: String { common.id }
    
    /// The version of the message.
    public var version: String { common.version }
    
    /// The origination data of the request.
    public var destination: Beacon.Connection.ID { common.destination }
    
    private var common: BlockchainBeaconResponseProtocol {
        switch self {
        case let .submit(content):
            return content
        case let .submitAndReturn(content):
            return content
        case let .`return`(content):
            return content
        }
    }
    
    // MARK: Types
    
    enum Error: Swift.Error {
        case invalidResponseMode
    }
}
