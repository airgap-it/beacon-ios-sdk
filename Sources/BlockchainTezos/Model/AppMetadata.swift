//
//  AppMetadata.swift
//  
//
//  Created by Julia Samol on 06.01.22.
//

import Foundation
import BeaconCore

extension Tezos {
    
    /// Metadata describing a Tezos dApp.
    public struct AppMetadata: AppMetadataProtocol {
        
        public static let blockchainIdentifier: String? = Tezos.identifier
        
        /// The value that identifies the dApp.
        public let senderID: String
        
        /// The name of the dApp.
        public let name: String
        
        /// An optional URL for the dApp icon.
        public let icon: String?
        
        init(senderID: String, name: String, icon: String? = nil) {
            self.senderID = senderID
            self.name = name
            self.icon = icon
        }
    }
}
