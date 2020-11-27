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
    private static let examplePeerPublicKey = "da58fa0a0912ecc62b4467721416ae4669e90ade4987086ee5c23d20075ad15c"
    private static let examplePeerRelayServer = "matrix.papers.tech"
    
    private static let exampleTezosPublicKey = "edpktpzo8UZieYaJZgCHP6M6hKHPdWBSNqxvmEt6dwWRgxDh1EAFw9"
    
    @Published var beaconRequest: String? = nil
    private var awaitingRequest: Beacon.Request? = nil
    
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
    
    func sendResponse() {
        guard let request = awaitingRequest else {
            return
        }
        
        beaconRequest = nil
        awaitingRequest = nil
        
        switch request {
        case let .permission(permission):
            let response = Beacon.Response.Permission(
                id: permission.id,
                publicKey: BeaconViewModel.exampleTezosPublicKey,
                network: permission.network,
                scopes: permission.scopes
            )
            beaconClient?.respond(with: .permission(response)) { result in
                switch result {
                case .success(_):
                    print("Sent the response")
                case let .failure(error):
                    print("Failed to send the response, got error: \(error)")
                }
            }
        default:
            // TODO
            return
        }
    }
    
    func removePeer() {
        beaconClient?.remove([.p2p(exampleP2PPeer)]) { result in
            switch result {
            case .success(_):
                print("Successfully removed peers")
            case let .failure(error):
                print("Failed to remove peers, got error: \(error)")
            }
        }
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
                self.awaitingRequest = request
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
