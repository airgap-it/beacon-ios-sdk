//
//  P2PMatrixMigration.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

extension Migration {
    func migrateMatrixRelayServer(withNodes matrixNodes: [String], completion: @escaping (Result<(), Swift.Error>) -> ()) {
        migrate(P2PMatrix.Target.matrixRelayServer(.init(matrixNodes: matrixNodes)), completion: completion)
    }
}
