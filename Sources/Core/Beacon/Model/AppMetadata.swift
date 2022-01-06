//
//  AppMetadata.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

/// Metadata describing a dApp.
public protocol AppMetadataProtocol {
    
    /// The value that identifies the dApp.
    var senderID: String { get }
    
    /// The name of the dApp.
    var name: String { get }
    
    /// An optional URL for the dApp icon.
    var icon: String? { get }
}

// MARK: Any

public struct AnyAppMetadata: AppMetadataProtocol, Codable, Equatable {
    public let senderID: String
    public let name: String
    public let icon: String?
    
    public init(_ appMetadata: AppMetadataProtocol) {
        self.senderID = appMetadata.senderID
        self.name = appMetadata.name
        self.icon = appMetadata.icon
    }
    
    public init(senderID: String, name: String, icon: String? = nil) {
        self.senderID = senderID
        self.name = name
        self.icon = icon
    }
}
