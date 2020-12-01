//
//  ConnectionControllerProtocol.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol ConnectionControllerProtocol {
    func connect(completion: @escaping (Result<(), Error>) -> ())
    func listen(onRequest listener: @escaping (Result<BeaconConnectionMessage, Error>) -> ())
    func send(_ message: BeaconConnectionMessage, completion: @escaping (Result<(), Error>) -> ())
    
    func onNew(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ())
    func onDeleted(_ peers: [Beacon.PeerInfo], completion: @escaping (Result<(), Error>) -> ())
}
