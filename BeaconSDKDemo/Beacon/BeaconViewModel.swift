//
//  BeaconViewModel.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconSDK

class BeaconViewModel: ObservableObject {
    private static let examplePeerName = "Beacon Example Dapp"
    private static let examplePeerPublicKey = "db359282649b3398ddd7b4d08ac74d95cf80184c4f7b33983b3df08113a3e1dd"
    private static let examplePeerRelayServer = "matrix.papers.tech"
    
    @Published var beaconRequest: String?
    
    private var beaconClient: Beacon.Client?
    
    private lazy var exampleP2PPeer: Beacon.P2PPeerInfo =
        Beacon.P2PPeerInfo(
            name: BeaconViewModel.examplePeerName,
            publicKey: BeaconViewModel.examplePeerPublicKey,
            relayServer: BeaconViewModel.examplePeerRelayServer
        )
    
    init() {
        startBeacon()
    }
    
    private func startBeacon() {
        Beacon.Client.create(with: Beacon.Client.Configuration(name: "iOS Beacon SDK Demo")) { [weak self] result in
            switch result {
            case let .success(client):
                self?.beaconClient = client
                self?.listenForRequests()
            case let .failure(error):
                print("Could not create Beacon clinet, got error: \(error)")
            }
        }
    }
    
    private func listenForRequests() {
        beaconClient?.connect(onRequest: onBeaconRequest) { result in
            switch result {
            case .success(_):
                self.beaconClient?.add([.p2p(self.exampleP2PPeer)]) { result in
                    switch result {
                    case .success(_):
                        print("Example peer added")
                    case let .failure(error):
                        print("Could not add the example peer, got error: \(error)")
                    }
                }
            case let .failure(error):
                print("Error while connecting for messages \(error)")
            }
        }
    }
    
    private func onBeaconRequest(result: Result<Beacon.Request, Error>) {
        switch result {
        case let .success(request):
            let encoder = JSONEncoder()
            let data = try? encoder.encode(request)
            
            DispatchQueue.main.async {
                self.beaconRequest = data.flatMap { String(data: $0, encoding: .utf8) }
            }
        case let .failure(error):
            print("Error while processing incoming messages: \(error)")
            break
        }
    }
}

extension Beacon.Request: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .permission(content):
            try content.encode(to: encoder)
        case let .operation(content):
            try content.encode(to: encoder)
        case let .signPayload(content):
            try content.encode(to: encoder)
        case let .broadcast(content):
            try content.encode(to: encoder)
        }
    }
}
