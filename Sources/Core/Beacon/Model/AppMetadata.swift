//
//  AppMetadata.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Metadata describing a dApp.
    public struct AppMetadata: Equatable, Codable {
        
        /// The value that identifies the dApp.
        public let senderID: String
        
        /// The name of the dApp.
        public let name: String
        
        /// An optional URL for the dApp icon.
        public let icon: String?
        
        public init(senderID: String, name: String, icon: String? = nil) {
            self.senderID = senderID
            self.name = name
            self.icon = icon
        }
    }
}
