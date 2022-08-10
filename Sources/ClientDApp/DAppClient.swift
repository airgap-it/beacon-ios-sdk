//
//  File.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation
import BeaconCore

extension Beacon {
    
    public class DAppClient: Client, BeaconProducer {
        
        public func request<B: Blockchain>(with request: BeaconRequest<B>, completion: @escaping (_ result: Result<(), Beacon.Error>) -> ()) {
            
        }
        
        public func pair(using connectionKind: Beacon.Connection.Kind, onMessage listener: @escaping (Result<BeaconPairingMessage, Beacon.Error>) -> ()) {
            connectionController.pair(using: connectionKind) { result in
                listener(result.withBeaconError())
            }
        }
    }
}
