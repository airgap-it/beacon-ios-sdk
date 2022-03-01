//
//  AppMetadataV2_0_0.swift
//  
//
//  Created by Julia Samol on 01.03.22.
//

import Foundation
import BeaconCore

extension Tezos {
    
    struct AppMetadataV2_0_0: LegacyAppMetadataProtocol {
        static let fromVersion: String = Migration.Tezos.From2_0_0.fromVersion
        static let blockchainIdentifier: String? = nil
        
        let senderID: String
        let name: String
        let icon: String?
        
        init(senderID: String, name: String, icon: String? = nil) {
            self.senderID = senderID
            self.name = name
            self.icon = icon
        }
    }
}
