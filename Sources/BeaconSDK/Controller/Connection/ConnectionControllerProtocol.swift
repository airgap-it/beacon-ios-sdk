//
//  ConnectionControllerProtocol.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol ConnectionControllerProtocol {
    func subscribe(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> (), completion: @escaping (Result<(), Error>) -> ())
    func send(_ message: BeaconConnectionMessage, completion: @escaping (Result<(), Error>) -> ())
    
    func on(new peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ())
    func on(deleted peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ())
}
