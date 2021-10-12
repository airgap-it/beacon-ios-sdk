//
//  BlockchainRegistry.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class BlockchainRegistry: BlockchainRegistryProtocol {
    private var blockchains: [String: AnyBlockchain] = [:]
    private var factories: [String: () -> AnyBlockchain]
    
    init(factories: [String: () -> AnyBlockchain]) {
        self.factories = factories
    }
    
    func get<T: Blockchain>() -> T? {
        get(ofType: T.identifier)?.unbox()
    }
    
    func get(ofType identifier: String) -> AnyBlockchain? {
        blockchains.get(identifier) {
            factories.getAndDispose(identifier)?()
        }
    }
    
}

public protocol BlockchainRegistryProtocol {
    func get<T: Blockchain>() -> T?
    func get(ofType identifier: String) -> AnyBlockchain?
}
