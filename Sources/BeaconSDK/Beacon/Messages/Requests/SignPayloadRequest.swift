//
//  SignPayloadRequest.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon.Request {
    
    public struct SignPayload: Equatable, Codable {
        public let id: String
        public let senderID: String
        public let appMetadata: Beacon.AppMetadata?
        public let payload: String
        public let sourceAddress: String
        public let origin: Beacon.Origin
    }
}
