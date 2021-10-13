//
//  MigrationFrom1_0_4.swift
//
//
//  Created by Julia Samol on 27.08.21.
//

import Foundation
import BeaconCore

extension Migration.P2PMatrix {
    
    struct From1_0_4: VersionedMigration {
        private static let v1_0_4DefaultNode: String = "matrix.papers.tech"
        
        let fromVersion: String = "1.0.4"
        
        private let storageManager: StorageManager
        
        init(storageManager: StorageManager) {
            self.storageManager = storageManager
        }
        
        func targets(_ target: MigrationTarget) -> Bool {
            guard let target = target as? Target else {
                return false
            }
            
            switch target {
            case .matrixRelayServer(_):
                return true
            }
        }
        
        func perform(on target: MigrationTarget, completion: @escaping (Result<(), Error>) -> ()) {
            guard let target = target as? Target else {
                return skip(completion: completion)
            }
            
            switch target {
            case let .matrixRelayServer(content):
                migrateMatrixRelayServer(with: content, completion: completion)
            }
        }
        
        // MARK: Target Actions
        
        private func migrateMatrixRelayServer(with target: Target.MatrixRelayServer, completion: @escaping (Result<(), Error>) -> ()) {
            storageManager.getMatrixRelayServer { relayServerResult in
                guard let relayServer = relayServerResult.get(ifFailure: completion) else { return }
                guard relayServer == nil else {
                    /* a relay server is set, no need to perform the migration */
                    self.skip(completion: completion)
                    return
                }

                guard target.matrixNodes == Beacon.P2PMatrixConfiguration.defaultRelayServers else {
                    /* the migration can't be performed if the list of nodes differs from the default list */
                    self.skip(completion: completion)
                    return
                }

                self.storageManager.getMatrixSyncToken { syncTokenResult in
                    guard let syncToken = syncTokenResult.get(ifFailure: completion) else { return }
                    self.storageManager.getMatrixRooms { roomsResult in
                        guard let rooms = roomsResult.get(ifFailure: completion) else { return }
                        guard syncToken != nil || !rooms.isEmpty else {
                            /* no connection that needs to be maintained */
                            self.skip(completion: completion)
                            return
                        }

                        /* use the old default node to avoid peers from losing their relay server */
                        self.storageManager.setMatrixRelayServer(From1_0_4.v1_0_4DefaultNode, completion: completion)
                    }
                }
            }
        }
    }
}
