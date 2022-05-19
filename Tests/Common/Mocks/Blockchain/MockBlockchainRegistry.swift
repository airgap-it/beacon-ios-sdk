//
//  MockBlockchainRegistry.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconCore
@testable import BeaconBlockchainTezos

public struct MockBlockchainRegistry: BlockchainRegistryProtocol {
    private let mockBlockchain: ShadowBlockchain
    
    public init(mockBlockchain: MockBlockchain = .init()) {
        self.mockBlockchain = mockBlockchain
    }
    
    public func get<T: Blockchain>() -> T? {
        get(ofType: T.identifier) as? T
    }
    
    public func get(ofType identifier: String) -> ShadowBlockchain? {
        mockBlockchain
    }
    
    public func getAll() -> [ShadowBlockchain] {
        [mockBlockchain]
    }
}
