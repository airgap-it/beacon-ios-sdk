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
        
        var identifier: String {
            switch self {
            case let .request(content):
                return content.identifier
            case let .response(content):
                return content.identifier
            case let .disconnect(content):
                return content.id
            }
        }
    }
}
