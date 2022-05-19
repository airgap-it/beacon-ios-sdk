//
//  BlockchainRegistry.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class BlockchainRegistry: BlockchainRegistryProtocol {
    private var blockchains: [String: ShadowBlockchain] = [:]
    private var factories: [String: () -> ShadowBlockchain]
    
    init(factories: [String: () -> ShadowBlockchain]) {
        self.factories = factories
    }
    
    func get<T: Blockchain>() -> T? {
        get(ofType: T.identifier) as? T
    }
    
    func get(ofType identifier: String) -> ShadowBlockchain? {
        blockchains.get(identifier) {
            factories.getAndDispose(identifier)?()
        }
    }
    
    func getAll() -> [ShadowBlockchain] {
        assertAllBuilt()
        
        return Array(blockchains.values)
    }
    
    private func assertAllBuilt() {
        guard !factories.isEmpty else {
            return
        }
        
        blockchains.merge(factories.buildAll(), uniquingKeysWith: { $1 })
        factories.removeAll()
    }
}

public protocol BlockchainRegistryProtocol {
    func get<T: Blockchain>() -> T?
    func get(ofType identifier: String) -> ShadowBlockchain?
    func getAll() -> [ShadowBlockchain]
}

// MARK: Exteneions

private extension Dictionary where Key == String, Value == () -> ShadowBlockchain {
    func buildAll() -> [String: ShadowBlockchain] {
        [String: ShadowBlockchain](map({ ($0.key, $0.value()) }), uniquingKeysWith: { $1 })
    }
}
