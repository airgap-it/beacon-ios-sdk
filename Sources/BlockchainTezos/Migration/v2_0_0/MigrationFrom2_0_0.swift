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
            case .storage(_):
                return true
            }
        }
        
        func perform(on target: MigrationTarget, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            guard let target = target as? Target else {
                return skip(completion: completion)
            }
            
            switch target {
            case let .storage(content):
                migrateStorage(with: content, completion: completion)
            }
        }
        
        // MARK: Target Actions
        
        private func migrateStorage(with target: Target.Storage, completion: @escaping (Result<(), Swift.Error>) -> ()) {
            migrateAppMetadata { appMetadataResult in
                guard appMetadataResult.isSuccess(else: completion) else { return }
                migratePermissions(completion: completion)
            }
        }
        
        private func migrateAppMetadata(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            migrateStorageContent(
                transform: { Tezos.AppMetadata($0) },
                select: storageManager.getAppMetadata,
                selectLegacy: storageManager.getLegacyAppMetadata,
                add: { self.storageManager.add($0, overwrite: true, completion: $1) },
                insertLegacy: storageManager.setLegacy,
                remove: storageManager.removeAppMetadata,
                removeLegacy: storageManager.removeLegacyAppMetadata,
                completion: completion
            )
        }
        
        private func migratePermissions(completion: @escaping (Result<(), Swift.Error>) -> ()) {
            migrateStorageContent(
                transform: { Tezos.Permission($0) },
                select: storageManager.getPermissions,
                selectLegacy: storageManager.getLegacyPermissions,
                add: { self.storageManager.add($0, overwrite: true, completion: $1) },
                insertLegacy: storageManager.setLegacy,
                remove: storageManager.removePermissions,
                removeLegacy: storageManager.removeLegacyPermissions,
                completion: completion
            )
        }
        
        private typealias SelectCollection<T> = (@escaping (Result<[T], Error>) -> ()) -> ()
        private typealias InsertCollection<T> = ([T], @escaping (Result<(), Error>) -> ()) -> ()
        private typealias RemoveCollection<T> = (T.Type, @escaping (Result<(), Error>) -> ()) -> ()
        private typealias RemoveCollectionWhere<T> = (@escaping (T) -> Bool, @escaping (Result<(), Error>) -> ()) -> ()

        private typealias TransformElement<T, S> = (T) -> S
        
        private func migrateStorageContent<T: Equatable, S: Equatable>(
            transform: @escaping TransformElement<S, T>,
            select: @escaping SelectCollection<S>,
            selectLegacy: @escaping SelectCollection<S>,
            add: @escaping InsertCollection<T>,
            insertLegacy: @escaping InsertCollection<S>,
            remove: @escaping RemoveCollectionWhere<S>,
            removeLegacy: @escaping RemoveCollection<S>,
            completion: @escaping (Result<(), Error>) -> ()
        ) {
            select { selectResult in
                guard let content = selectResult.get(ifFailure: completion) else { return }
                
                selectLegacy { selectLegacyResult in
                    guard let legacyContent = selectLegacyResult.get(ifFailure: completion) else { return }
                    
                    let legacyMerged = content + legacyContent
                    
                    guard !legacyMerged.isEmpty else {
                        /* no legacy content to migrate */
                        self.skip(completion: completion)
                        return
                    }
                    
                    let newContent = legacyMerged.map { transform($0) }
                    insertLegacy(legacyMerged) { insertLegacyResult in
                        guard insertLegacyResult.isSuccess(else: completion) else { return }
                        remove({ content.contains($0) }) { removeResult in
                            add(newContent) { addResult in
                                guard addResult.isSuccess(else: completion) else { return }
                                removeLegacy(S.self, completion)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: Extensions

private extension Tezos.AppMetadata {
    init(_ legacy: Tezos.AppMetadataV2_0_0) {
        self.senderID = legacy.senderID
        self.name = legacy.name
        self.icon = legacy.icon
    }
}

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
