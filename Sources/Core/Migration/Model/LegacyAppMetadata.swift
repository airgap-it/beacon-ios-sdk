//
//  LegacyAppMetadata.swift
//  
//
//  Created by Julia Samol on 01.03.22.
//

import Foundation

public protocol LegacyAppMetadata: AppMetadataProtocol, Equatable, Codable {
    static var fromVersion: String { get }
}
