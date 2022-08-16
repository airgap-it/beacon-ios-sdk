//
//  DAppViewModel.swift
//  BeaconSDKDemo
//
//  Created by Julia Samol on 11.08.22.
//

import Foundation
import BeaconCore
import BeaconBlockchainSubstrate
import BeaconBlockchainTezos
import BeaconClientDApp
import BeaconTransportP2PMatrix

class DAppViewModel: ObservableObject {
    
    @Published private(set) var started: Bool = false
    @Published private(set) var beaconResponse: String? = nil
    @Published private(set) var pairingRequest: String? = nil
    
    private var beaconClient: Beacon.DAppClient? = nil {
        didSet {
            started = beaconClient != nil
        }
    }
    
    init() {}
    
    func start() {
        startBeacon()
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
    
    func clearResponse() {
        DispatchQueue.main.async {
            self.beaconResponse = nil
        }
    }
    
    func requestPermission() {
        /* should be performed AFTER a successful pairing */
        
        beaconClient?.requestTezosPermission { result in
            switch result {
            case .success(_):
                print("Sent the request")
            case let .failure(error):
                print("Failed to send the request, got error: \(error)")
            }
        }
    }
    
    func pair() {
        self.beaconClient?.pair(using: .p2p) { result in
            switch result {
            case let .success(pairingMessage):
                switch pairingMessage {
                case let .request(pairingRequest):
                    if let serializedRequest = try? self.beaconClient?.serializePairingData(.request(pairingRequest)) {
                        DispatchQueue.main.async {
                            self.pairingRequest = serializedRequest
                        }
                    } else {
                        print("Failed to pair, unable to serialize a pairing request")
                    }
                case .response(_):
                    print("Pairing succeeded")
                }
            case let .failure(error):
                print("Failed to pair, got error: \(error)")
            }
        }
    }
    
    func unpair() {
        beaconClient?.removeAllPeers { result in
            switch result {
            case .success(_):
                print("Successfully removed peers")
            case let .failure(error):
                print("Failed to remove peers, got error: \(error)")
            }
        }
    }
    
    private func startBeacon() {
        guard beaconClient == nil else {
            listenForResponses()
            return
        }
        
        do {
            Beacon.DAppClient.create(
                with: .init(
                    name: "iOS Beacon SDK Demo (DApp)",
                    blockchains: [Tezos.factory, Substrate.factory],
                    connections: [try Transport.P2P.Matrix.connection()]
                )
            ) { result in
                switch result {
                case let .success(client):
                    print("Beacon client created")
                    
                    DispatchQueue.main.async {
                        self.beaconClient = client
                        self.listenForResponses()
                    }
                case let .failure(error):
                    print("Could not create Beacon client, got error: \(error)")
                }
            }
        } catch {
            print("Could not create Beacon client, got error: \(error)")
        }
    }
    
    private func listenForResponses() {
        beaconClient?.connect { result in
            switch result {
            case .success(_):
                print("Beacon client connected")
                self.beaconClient?.listen(onResponse: self.onTezosResponse)
                self.beaconClient?.listen(onResponse: self.onSubstrateResponse)
            case let .failure(error):
                print("Error while connecting for messages \(error)")
            }
        }
    }
    
    private func onTezosResponse(_ responseResult: Result<BeaconResponse<Tezos>, Beacon.Error>) {
        onBeaconResponse(responseResult)
    }
    
    private func onSubstrateResponse(_ responseResult: Result<BeaconResponse<Substrate>, Beacon.Error>) {
        onBeaconResponse(responseResult)
    }
    
    private func onBeaconResponse<B: Blockchain>(_ result: Result<BeaconResponse<B>, Beacon.Error>, completion: @escaping (Result<BeaconResponse<B>, Swift.Error>) -> () = { _ in }) {
        switch result {
        case let .success(request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let data = try? encoder.encode(request)
            
            DispatchQueue.main.async {
                self.beaconResponse = data.flatMap { String(data: $0, encoding: .utf8) }
                completion(.success(request))
            }
        case let .failure(error):
            print("Error while processing incoming messages: \(error)")
            completion(.failure(error))
        }
    }
}

extension BeaconResponse: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        if let tezosResponse = self as? BeaconResponse<Tezos> {
            switch tezosResponse {
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
            case let .acknowledge(content):
                try content.encode(to: encoder)
            case let .error(content):
                try content.encode(to: encoder)
            }
        } else if let substrateResponse = self as? BeaconResponse<Substrate> {
            switch substrateResponse {
            case let .permission(content):
                try content.encode(to: encoder)
            case let .blockchain(blockchain):
                switch blockchain {
                case let .transfer(transfer):
                    switch transfer {
                    case let .submit(content):
                        try content.encode(to: encoder)
                    case let .submitAndReturn(content):
                        try content.encode(to: encoder)
                    case let .return(content):
                        try content.encode(to: encoder)
                    }
                case let .signPayload(signPayload):
                    switch signPayload {
                    case let .submit(content):
                        try content.encode(to: encoder)
                    case let .submitAndReturn(content):
                        try content.encode(to: encoder)
                    case let .return(content):
                        try content.encode(to: encoder)
                    }
                }
            case let .acknowledge(content):
                try content.encode(to: encoder)
            case let .error(content):
                try content.encode(to: encoder)
            }
        } else {
            throw Error.unsupportedBlockchain
        }
    }
    
    enum Error: Swift.Error {
        case unsupportedBlockchain
    }
}
