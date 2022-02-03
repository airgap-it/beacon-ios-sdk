//
//  Migration+Additions.swift
//  
//
//  Created by Julia Samol on 02.02.22.
//

import Foundation
import BeaconCore

extension Migration {
    func migratePermissions(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        migrate(Tezos.Target.permissions(.init()), completion: completion)
    }
}
