//
//  BlockchainVersionedMessage.swift
//
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainVersionedMessage {
    associatedtype V1: BlockchainV1Message
    associatedtype V2: BlockchainV2Message
    associatedtype V3: BlockchainV3Message
}

public protocol BlockchainV1Message: V1BeaconMessageProtocol & Equatable & Codable {}

public protocol BlockchainV2Message: V2BeaconMessageProtocol & Equatable & Codable {}

public protocol BlockchainV3Message {
    associatedtype PermissionRequestContentData: PermissionV3BeaconRequestContentDataProtocol & Equatable & Codable
    associatedtype BlockchainRequestContentData: BlockchainV3BeaconRequestContentDataProtocol & Equatable & Codable
    
    associatedtype PermissionResponseContentData: PermissionV3BeaconResponseContentDataProtocol & Equatable & Codable
    associatedtype BlockchainResponseContentData: BlockchainV3BeaconResponseContentDataProtocol & Equatable & Codable
}
