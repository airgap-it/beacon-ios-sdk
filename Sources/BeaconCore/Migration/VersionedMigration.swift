//
//  VersionedMigration.swift
//  
//
//  Created by Julia Samol on 27.08.21.
//

import Foundation
    
public protocol VersionedMigration {
    var fromVersion: String { get }
    
    func targets(_ target: MigrationTarget) -> Bool
    func perform(on target: MigrationTarget, completion: @escaping (Result<(), Swift.Error>) -> ())
}

// MARK: Extensions

public extension VersionedMigration {
    func migrationIdentifier(target: MigrationTarget) -> String {
        "from_\(fromVersion)@\(target.identifier)"
    }
    
    func skip(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        completion(.success(()))
    }
}
