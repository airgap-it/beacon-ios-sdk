//
//  AppMetadata.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public struct AppMetadata: Equatable, Codable {
        public let senderID: String
        public let name: String
        public let icon: String?
        
        public init(senderID: String, name: String, icon: String? = nil) {
            self.senderID = senderID
            self.name = name
            self.icon = icon
        }
    }
}
