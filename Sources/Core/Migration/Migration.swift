//
//  Migration.swift
//  
//
//  Created by Julia Samol on 27.08.21.
//

import Foundation

public class Migration {
    let storageManager: StorageManager
    public private(set) var migrations: [VersionedMigration] = [] {
        didSet {
            migrations.distinguish(by: { $0.fromVersion })
            migrations.sort(by: { lhs, rhs in lhs.fromVersion < rhs.fromVersion })
        }
    }
    
    private var sdkVersion: String?
    
    init(storageManager: StorageManager, migrations: [VersionedMigration]) {
        self.storageManager = storageManager
        self.migrations = migrations
    }
    
    // MARK: Migrations
    
    public func register(_ migrations: [VersionedMigration]) {
        self.migrations.append(contentsOf: migrations)
    }
    
    public func migrate(_ target: MigrationTarget, completion: @escaping (Result<(), Swift.Error>) -> ()) {
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
    
    // MARK: Private
    
    private func migrate(
        _ target: MigrationTarget,
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

private extension VersionedMigration {
    
    func hasPerformed(
        _ target: MigrationTarget,
        ifAlreadyPerformed performedMigrations: Set<String>,
        atVersion sdkVersion: String?
    ) -> Bool {
        if let sdkVersion = sdkVersion, sdkVersion <= fromVersion {
            return true
        }
        
        let migrationIdentifier = migrationIdentifier(target: target)
        return performedMigrations.contains(migrationIdentifier)
    }
}
