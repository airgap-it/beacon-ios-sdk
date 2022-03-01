//
//  Migration+Additions.swift
//  
//
//  Created by Julia Samol on 02.02.22.
//

import Foundation
import BeaconCore

extension Migration {
    func migrateStorage(completion: @escaping (Result<(), Swift.Error>) -> ()) {
        migrate(Tezos.Target.storage(.init()), completion: completion)
    }
}
