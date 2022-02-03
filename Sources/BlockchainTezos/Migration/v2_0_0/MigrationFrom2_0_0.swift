//
//  MigrationFrom2_0_0.swift
//  
//
//  Created by Julia Samol on 02.02.22.
//

import Foundation
import BeaconCore

extension Migration.Tezos {
    
    struct From2_0_0: VersionedMigration {
        static let fromVersion: String = "2.0.0"
        var fromVersion: String { From2_0_0.fromVersion }
        
        private let storageManager: StorageManager
        
        init(storageManager: StorageManager) {
            self.storageManager = storageManager
        }
        
        func targets(_ target: MigrationTarget) -> Bool {
            guard let target = target as? Target else {
                return false
            }
            
            switch target {
            case .permissions(_):
                return true
            }
        }
        
        func perform(on target: MigrationTarget, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            guard let target = target as? Target else {
                return skip(completion: completion)
            }
            
            switch target {
            case let .permissions(content):
                migratePermissions(with: content, completion: completion)
            }
        }
        
        // MARK: Target Actions
        
        private func migratePermissions(with target: Target.Permissions, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            storageManager.getPermissions { (permissionsResult: Result<[Tezos.PermissionV2_0_0], Swift.Error>) in
                guard let permissions = permissionsResult.get(ifFailure: completion) else { return }
                
                self.storageManager.getLegacyPermissions { (legacyPermissionsResult: Result<[Tezos.PermissionV2_0_0], Swift.Error>) in
                    guard let legacyPermissions = legacyPermissionsResult.get(ifFailure: completion) else { return }
                    
                    let legacyMerged = permissions + legacyPermissions
                
                    guard !legacyMerged.isEmpty else {
                        /* no legacy permissions to migrate */
                        self.skip(completion: completion)
                        return
                    }
                    
                    let newPermissions = legacyMerged.map { Tezos.Permission($0) }
                    self.storageManager.setLegacy(legacyMerged) { setLegacyResult in
                        guard setLegacyResult.isSuccess(else: completion) else { return }
                        self.storageManager.removePermissions(where: { (permission: Tezos.PermissionV2_0_0) in permissions.contains(permission) }) { removePermissionsResult in
                            guard removePermissionsResult.isSuccess(else: completion) else { return }
                            self.storageManager.add(newPermissions, overwrite: true) { addNewResult in
                                guard addNewResult.isSuccess(else: completion) else { return }
                                self.storageManager.removeLegacyPermissions(ofType: Tezos.PermissionV2_0_0.self, completion: completion)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Extensions

private extension Tezos.Permission {
    init(_ legacy: Tezos.PermissionV2_0_0) {
        self.accountID = legacy.accountID
        self.senderID = legacy.senderID
        self.connectedAt = legacy.connectedAt
        self.address = legacy.address
        self.publicKey = legacy.publicKey
        self.network = legacy.network
        self.appMetadata = legacy.appMetadata
        self.scopes = legacy.scopes.compactMap {
            switch $0 {
            case .sign:
                return .sign
            case .operationRequest:
                return .operationRequest
            default:
                return nil
            }
        }
    }
}
