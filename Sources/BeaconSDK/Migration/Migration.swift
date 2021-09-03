//
//  Migration.swift
//  
//
//  Created by Julia Samol on 27.08.21.
//

import Foundation

class Migration {
    let storageManager: StorageManager
    let migrations: [VersionedMigration]
    
    private var sdkVersion: String?
    
    init(storageManager: StorageManager, migrations: [VersionedMigration]) {
        migrations.requireUnique()
        
        self.storageManager = storageManager
        self.migrations = migrations.sorted(by: { lhs, rhs in lhs.fromVersion < rhs.fromVersion })
    }
    
    // MARK: Migrations
    
    func migrateMatrixRelayServer(withNodes matrixNodes: [String], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        migrate(.matrixRelayServer(.init(matrixNodes: matrixNodes)), completion: completion)
    }
    
    // MARK: Private
    
    private func migrate(_ target: Target, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        sdkVersion { sdkVersionResult in
            guard let sdkVersion = sdkVersionResult.get(ifFailure: completion) else { return }
            self.storageManager.getMigrations { migrationsResult in
                guard let performedMigrations = migrationsResult.get(ifFailure: completion) else { return }
                
                let migrations = self.migrations.filter {
                    $0.targets(target) && !$0.hasPerformed(target, ifAlreadyPerformed: performedMigrations, atVersion: sdkVersion)
                }
                
                self.migrate(target, using: migrations, completion: completion)
            }
        }
    }
    
    private func migrate(
        _ target: Target,
        using migrations: [VersionedMigration],
        withCompleted completed: Set<String> = [],
        completion: @escaping (Result<(), Swift.Error>) -> ()
    ) {
        guard let next = migrations.first else {
            saveMigrations(completed, completion: completion)
            return
        }
        
        next.perform(on: target) { result in
            switch result {
            case .success(_):
                let identifier = next.migrationIdentifier(target: target)
                self.migrate(target, using: Array(migrations.dropFirst()), withCompleted: completed.union([identifier]), completion: completion)
            case let .failure(error):
                self.saveMigrations(completed) { _ in
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func saveMigrations(_ completed: Set<String>, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        guard completed.count > 0 else {
            completion(.success(()))
            return
        }
        
        storageManager.addMigrations(completed, completion: completion)
    }
    
    private func sdkVersion(completion: @escaping (Result<String?, Swift.Error>) -> ()) {
        guard let sdkVersion = sdkVersion else {
            storageManager.getSDKVersion { result in
                guard let sdkVersion = result.get(ifFailure: completion) else { return }
                self.sdkVersion = sdkVersion
                
                completion(.success(sdkVersion))
            }
            return
        }
        
        completion(.success(sdkVersion))
    }
}

// MARK: Extensions

private extension Array where Element == VersionedMigration {
    
    func requireUnique() {
        if let duplicate = grouped(by: { $0.fromVersion }).mapValues({ $0.count }).first(where: { $0.value > 1 }) {
            preconditionFailure("Duplicated migration from version \(duplicate.key)")
        }
    }
}

private extension VersionedMigration {
    
    func hasPerformed(
        _ target: Migration.Target,
        ifAlreadyPerformed performedMigrations: Set<String>,
        atVersion sdkVersion: String?
    ) -> Bool {
        if let sdkVersion = sdkVersion, sdkVersion > fromVersion {
            return true
        }
        
        let migrationIdentifier = migrationIdentifier(target: target)
        return performedMigrations.contains(migrationIdentifier)
    }
}
