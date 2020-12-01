//
//  Message.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public enum Message {
        case request(Request)
        case response(Response)
        case disconnect(Disconnect)
        
        // MARK: Attributes
        
        var common: MessageProtocol {
            switch self {
            case let .request(content):
                return content.common
            case let .response(content):
                return content.common
            case let .disconnect(content):
                return content
            }
        }
    }
}

// MARK: Protocol

protocol MessageProtocol {
    var id: String { get }
}
