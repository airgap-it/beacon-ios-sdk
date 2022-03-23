//
//  AnyLegacyAppMetadata.swift
//  
//
//  Created by Julia Samol on 01.03.22.
//

import Foundation
import BeaconCore

public struct AnyLegacyAppMetadata: LegacyAppMetadataProtocol {
    public static var fromVersion: String = ""
    public static var blockchainIdentifier: String? = nil
    
    public let senderID: String
    public let name: String
    public let icon: String?
    
    public init(senderID: String, name: String, icon: String? = nil) {
        self.senderID = senderID
        self.name = name
        self.icon = icon
    }
    
    public init<T: LegacyAppMetadataProtocol>(_ legacyAppMedata: T) {
        self.init(senderID: legacyAppMedata.senderID, name: legacyAppMedata.name, icon: legacyAppMedata.icon)
    }
}
