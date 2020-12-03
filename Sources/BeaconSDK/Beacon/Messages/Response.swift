//
//  Response.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public enum Response: Equatable {
        case permission(Permission)
        case operation(Operation)
        case signPayload(SignPayload)
        case broadcast(Broadcast)
        case error(Error)
        
        // MARK: Attributes
        
        var common: ResponseProtocol {
            switch self {
            case let .permission(content):
                return content
            case let .operation(content):
                return content
            case let .signPayload(content):
                return content
            case let .broadcast(content):
                return content
            case let .error(content):
                return content
            }
        }
    }
}

// MARK: Protocol

protocol ResponseProtocol: MessageProtocol {}
