//
//  Producer.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public protocol BeaconProducer {
    
    func request<B: Blockchain>(with request: BeaconRequest<B>, completion: @escaping (_ result: Result<(), Beacon.Error>) -> ())
    
    func pair(using connectionKind: Beacon.Connection.Kind, onMessage listener: @escaping (Result<BeaconPairingMessage, Beacon.Error>) -> ())
}
