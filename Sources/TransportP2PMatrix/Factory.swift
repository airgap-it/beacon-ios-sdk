//
//  P2PMatrixFactory.swift
//  
//
//  Created by Julia Samol on 30.09.21.
//

import Foundation
import BeaconCore

extension Transport.P2P.Matrix {
    
    /// P2PMatrix factory that should be used to dynamically register the P2P client in Beacon.
    public class Factory: P2PClientFactory {
        private let storagePlugin: P2PMatrixStoragePlugin
        private let matrixNodes: [String]
        private let urlSession: URLSession
        
        private var extendedDependencyRegistry: ExtendedDependencyRegistry?
        private func extendedDependencyRegistry(from dependencyRegistry: DependencyRegistry) -> ExtendedDependencyRegistry {
            guard let value = extendedDependencyRegistry else {
                let value = dependencyRegistry.extend()
                extendedDependencyRegistry = value
                
                return value
            }
            
            return value
        }
        
        init(
            storagePlugin: P2PMatrixStoragePlugin? = nil,
            matrixNodes: [String] = Beacon.P2PMatrixConfiguration.defaultRelayServers,
            urlSession: URLSession = .shared
        ) throws {
            guard !matrixNodes.isEmpty else {
                throw Beacon.Error.emptyNodes
            }
            
            self.storagePlugin = storagePlugin ?? UserDefaultsP2PMatrixStoragePlugin()
            self.matrixNodes = matrixNodes
            self.urlSession = urlSession
        }
        
        public func create(with dependencyRegistry: DependencyRegistry) throws -> P2PClient {
            let extendedDependencyRegistry = extendedDependencyRegistry(from: dependencyRegistry)
            return try extendedDependencyRegistry.p2pMatrix(storagePlugin: storagePlugin, matrixNodes: matrixNodes, urlSession: urlSession)
        }
    }
}
