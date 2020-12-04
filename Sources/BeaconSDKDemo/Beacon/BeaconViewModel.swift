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
    private static let examplePeerID = "a59fb446-7913-2fdc-3267-02149f0b1c4e"
    private static let examplePeerName = "Beacon Example Dapp"
    private static let examplePeerPublicKey = "100247a23a014e5b005d4e6406bfce1cfa7d7ed4f0e4ee63f0ce566fca996551"
    private static let examplePeerRelayServer = "matrix.papers.tech"
    private static let examplePeerVersion = "2"
    
    private static let exampleTezosPublicKey = "edpktpzo8UZieYaJZgCHP6M6hKHPdWBSNqxvmEt6dwWRgxDh1EAFw9"
    
    @Published private(set) var beaconRequest: String? = nil
    
    @Published var id: String = BeaconViewModel.examplePeerID
    @Published var name: String = BeaconViewModel.examplePeerName
    @Published var publicKey: String = BeaconViewModel.examplePeerPublicKey
    @Published var relayServer: String = BeaconViewModel.examplePeerRelayServer
    @Published var version: String = BeaconViewModel.examplePeerVersion
    
    private var awaitingRequest: Beacon.Request? = nil
    private var peer: Beacon.P2PPeer {
        Beacon.P2PPeer(
            id: id,
            name: name,
            publicKey: publicKey,
            relayServer: relayServer,
            version: version
        )
    }
    
    private var beaconClient: Beacon.Client?
    
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
            let response = Beacon.Response.Permission(from: permission, publicKey: BeaconViewModel.exampleTezosPublicKey)
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
    
    func addPeer() {
        self.beaconClient?.add([.p2p(peer)]) { result in
            switch result {
            case .success(_):
                print("Peer added")
            case let .failure(error):
                print("Could not add the peer, got error: \(error)")
            }
        }
    }
    
    func removePeer() {
        beaconClient?.remove([.p2p(peer)]) { result in
            switch result {
            case .success(_):
                print("Successfully removed peers")
            case let .failure(error):
                print("Failed to remove peers, got error: \(error)")
            }
        }
    }
    
    private func startBeacon() {
        Beacon.Client.create(with: Beacon.Client.Configuration(name: "iOS Beacon SDK Demo")) { result in
            switch result {
            case let .success(client):
                self.beaconClient = client
                self.listenForRequests()
            case let .failure(error):
                print("Could not create Beacon clinet, got error: \(error)")
            }
        }
    }
    
    private func listenForRequests() {
        beaconClient?.connect { result in
            switch result {
            case .success(_):
                self.beaconClient?.listen(onRequest: self.onBeaconRequest)
            case let .failure(error):
                print("Error while connecting for messages \(error)")
            }
        }
    }
    
    private func onBeaconRequest(result: Result<Beacon.Request, Beacon.Error>) {
        switch result {
        case let .success(request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
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
