//
//  VersionedMigration.swift
//  
//
//  Created by Julia Samol on 27.08.21.
//

import Foundation
    
protocol VersionedMigration {
    var fromVersion: String { get }
    
    func targets(_ target: Migration.Target) -> Bool
    func perform(on target: Migration.Target, completion: @escaping (Result<(), Swift.Error>) -> ())
}

// MARK: Extensions

extension VersionedMigration {
    func migrationIdentifier(target: Migration.Target) -> String {
        "from_\(fromVersion)@\(target.common.identifier)"
    }
    
    func skip(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        completion(.success(()))
    }
}
