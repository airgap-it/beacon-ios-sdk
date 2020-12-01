//
//  SignPayloadResponse.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Response {
    
    public struct SignPayload: ResponseProtocol, Equatable, Codable {
        public let id: String
        public let signature: String
    }
}
