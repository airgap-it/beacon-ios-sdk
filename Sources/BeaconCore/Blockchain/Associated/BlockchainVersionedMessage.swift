//
//  BlockchainVersionedMessage.swift
//
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainVersionedMessage {
    associatedtype V1: V1BeaconMessageProtocol & Equatable & Codable
    associatedtype V2: V2BeaconMessageProtocol & Equatable & Codable
}
