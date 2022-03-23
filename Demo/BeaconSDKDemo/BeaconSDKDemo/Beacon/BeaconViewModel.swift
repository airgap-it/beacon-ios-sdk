//
//  BeaconViewModel.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

import BeaconCore
import BeaconBlockchainSubstrate
import BeaconBlockchainTezos
import BeaconClientWallet
import BeaconTransportP2PMatrix

class BeaconViewModel: ObservableObject {
    private static let examplePeerID = "e3a82598-d047-59db-3e7e-12948caa6cbf"
    private static let examplePeerName = "Beacon Example Dapp"
    private static let examplePeerPublicKey = "4d318cbfc236985a44f6114cc46d62806e50d3d8c4e0867651e8e68efac8e37c"
    private static let examplePeerRelayServer = "beacon-node-1.sky.papers.tech"
    private static let examplePeerVersion = "3"
    
    private static func exampleTezosAccount(network: Tezos.Network) throws -> Tezos.Account {
        try Tezos.Account(
            publicKey: "edpktpzo8UZieYaJZgCHP6M6hKHPdWBSNqxvmEt6dwWRgxDh1EAFw9",
            address: "tz1Mg6uXUhJzuCh4dH2mdBdYBuaiVZCCZsak",
            network: network
        )
    }

    private static func exampleSubstrateAccount(network: Substrate.Network) throws -> Substrate.Account {
        try Substrate.Account(
            publicKey: "628f3940a6210a2135ba355f7ff9f8e9fbbfd04f8571e99e1df75554d4bcd24f",
            address: "5EHw6XmdpoaaJiPMXFKr1CcHcXPVYZemc9NoKHhEoguavzJN",
            network: network
        )
    }
    
    @Published private(set) var beaconRequest: String? = nil
    
    @Published var id: String = BeaconViewModel.examplePeerID
    @Published var name: String = BeaconViewModel.examplePeerName
    @Published var publicKey: String = BeaconViewModel.examplePeerPublicKey
    @Published var relayServer: String = BeaconViewModel.examplePeerRelayServer
    @Published var version: String = BeaconViewModel.examplePeerVersion
    
    private var awaitingTezosRequest: BeaconRequest<Tezos>? = nil
    private var awaitingSubstrateRequest: BeaconRequest<Substrate>? = nil
    
    private var peer: Beacon.P2PPeer {
        Beacon.P2PPeer(
            id: id,
            name: name,
            publicKey: publicKey,
            relayServer: relayServer,
            version: version
        )
    }
    
    private var beaconClient: Beacon.WalletClient?
    
    init() {
        startBeacon()
    }
    
    func sendResponse() {
        if let request = awaitingTezosRequest {
            beaconRequest = nil
            awaitingTezosRequest = nil
            
            do {
                beaconClient?.respond(with: try response(from: request)) { result in
                    switch result {
                    case .success(_):
                        print("Sent the response")
                    case let .failure(error):
                        print("Failed to send the response, got error: \(error)")
                    }
                }
            } catch {
                print("Failed to send the response, got error: \(error)")
            }
        }
        
        if let request = awaitingSubstrateRequest {
            beaconRequest = nil
            awaitingSubstrateRequest = nil
            
            do {
                beaconClient?.respond(with: try response(from: request)) { result in
                    switch result {
                    case .success(_):
                        print("Sent the response")
                    case let .failure(error):
                        print("Failed to send the response, got error: \(error)")
                    }
                }
            } catch {
                print("Failed to send the response, got error: \(error)")
            }
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
    
    func stop() {
        beaconClient?.disconnect {
            print("disconnected \($0)")
        }
    }
    
    func pause() {
        beaconClient?.pause {
            print("paused \($0)")
        }
    }
    
    func resume() {
        beaconClient?.resume {
            print("resumed \($0)")
        }
    }
    
    func startBeacon() {
        guard beaconClient == nil else {
            listenForRequests()
            return
        }
        
        do {
            Beacon.WalletClient.create(
                with: .init(
                    name: "iOS Beacon SDK Demo",
                    blockchains: [Tezos.factory, Substrate.factory],
                    connections: [try Transport.P2P.Matrix.connection()]
                )
            ) { result in
                switch result {
                case let .success(client):
                    print("Beacon client created")
                    self.beaconClient = client
                    self.listenForRequests()
                case let .failure(error):
                    print("Could not create Beacon client, got error: \(error)")
                }
            }
        } catch {
            print("Could not create Beacon client, got error: \(error)")
        }
    }
    
    private func listenForRequests() {
        beaconClient?.connect { result in
            switch result {
            case .success(_):
                print("Beacon client connected")
                self.beaconClient?.listen(onRequest: self.onTezosRequest)
                self.beaconClient?.listen(onRequest: self.onSubstrateRequest)
            case let .failure(error):
                print("Error while connecting for messages \(error)")
            }
        }
    }
    
    private func onTezosRequest(_ requestResult: Result<BeaconRequest<Tezos>, Beacon.Error>) {
        onBeaconRequest(requestResult) { result in
            switch result {
            case let .success(request):
                self.awaitingSubstrateRequest = nil
                self.awaitingTezosRequest = request
            case .failure(_):
                break
            }
        }
    }
    
    private func onSubstrateRequest(_ requestResult: Result<BeaconRequest<Substrate>, Beacon.Error>) {
        onBeaconRequest(requestResult) { result in
            switch result {
            case let .success(request):
                self.awaitingTezosRequest = nil
                self.awaitingSubstrateRequest = request
            case .failure(_):
                break
            }
        }
    }
    
    private func onBeaconRequest<B: Blockchain>(_ result: Result<BeaconRequest<B>, Beacon.Error>, completion: @escaping (Result<BeaconRequest<B>, Swift.Error>) -> ()) {
        switch result {
        case let .success(request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try? encoder.encode(request)
            
            DispatchQueue.main.async {
                self.beaconRequest = data.flatMap { String(data: $0, encoding: .utf8) }
                completion(.success(request))
            }
        case let .failure(error):
            print("Error while processing incoming messages: \(error)")
            completion(.failure(error))
        }
    }
        
    private func response(from request: BeaconRequest<Tezos>) throws -> BeaconResponse<Tezos> {
        switch request {
        case let .permission(content):
            return .permission(
                try PermissionTezosResponse(from: content, account: BeaconViewModel.exampleTezosAccount(network: content.network))
            )
        case let .blockchain(blockchain):
            switch blockchain {
            case .signPayload(_):
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .blockchain(.signatureTypeNotSupported)))
            default:
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
            }
        }
    }
    
    private func response(from request: BeaconRequest<Substrate>) throws -> BeaconResponse<Substrate> {
        switch request {
        case let .permission(content):
            return .permission(
                try PermissionSubstrateResponse(from: content, accounts: [BeaconViewModel.exampleSubstrateAccount(network: content.networks.first!)])
            )
        case let .blockchain(blockchain):
            switch blockchain {
            case let .signPayload(request):
                return .blockchain(.signPayload(try .init(from: request, transactionHash: nil, signature: "0x00050300724867a19e4a9422ac85f3b9a7c4bf5ccf12c2df60d858b216b81329df7165350005020000d22300000b00000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3fde8f6d19d4a685f5edeed50eb55b1755da0bf01e83946f6e41062113042999a", payload: nil)))
            default:
                return .error(ErrorBeaconResponse(from: blockchain, errorType: .aborted))
            }
        }
    }
}

extension BeaconRequest: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        if let tezosRequest = self as? BeaconRequest<Tezos> {
            switch tezosRequest {
            case let .permission(content):
                try content.encode(to: encoder)
            case let .blockchain(blockchain):
                switch blockchain {
                case let .operation(content):
                    try content.encode(to: encoder)
                case let .signPayload(content):
                    try content.encode(to: encoder)
                case let .broadcast(content):
                    try content.encode(to: encoder)
                }
            }
        } else if let substrateRequest = self as? BeaconRequest<Substrate> {
            switch substrateRequest {
            case let .permission(content):
                try content.encode(to: encoder)
            case let .blockchain(blockchain):
                switch blockchain {
                case let .transfer(content):
                    try content.encode(to: encoder)
                case let .signPayload(content):
                    try content.encode(to: encoder)
                }
            }
        } else {
            throw Error.unsupportedBlockchain
        }
    }
    
    enum Error: Swift.Error {
        case unsupportedBlockchain
    }
}
