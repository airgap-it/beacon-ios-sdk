//
//  ConnectionControllerTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
import Common

@testable import BeaconCore

class ConnectionControllerTests: XCTestCase {
    
    private var connectionController: ConnectionController!
    private var transports: [MockTransport]!
    private var serializer: MockSerializer!

    override func setUpWithError() throws {
        serializer = MockSerializer()
        transports = [
            MockTransport(kind: .p2p),
            MockTransport(kind: .p2p),
        ]
        connectionController = ConnectionController(transports: transports, serializer: serializer)
    }

    override func tearDownWithError() throws {
        connectionController = nil
        transports = nil
        serializer = nil
        
        clearBeacon()
    }

    func testControllerConnects() throws {
        let testExpectation = expectation(description: "ConnectionController connects")
        
        connectionController.connect { result in
            switch result {
            case .success(_):
                XCTAssertTrue(
                    self.transports.reduce(true) { (acc, next) in acc && next.startCalls == 1 },
                    "Expected all transports to call start"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerConnects timeout: \(error)")
            }
        }
    }
    
    func testControllerConnectsWithPartialError() throws {
        let testExpectation = expectation(description: "ConnectionController connects with partial error")
        guard let failingTransport = transports.first else {
            return
        }
        
        failingTransport.isFailing = true
        
        connectionController.connect { result in
            switch result {
            case .success(_):
                XCTFail("Expected error")
            case let .failure(error):
                guard let error = error as? Beacon.Error else {
                    XCTFail("Expected error to be Beacon.Error")
                    break
                }
                
                XCTAssertTrue(
                    self.transports.reduce(true) { (acc, next) in acc && next.startCalls == 1 },
                    "Expected all transports to call start"
                )
                
                switch error {
                case let .connectionFailed(kind, causedBy: _):
                    XCTAssertEqual([failingTransport.kind], kind, "Expected error to provide information of a kind of the failing transport")
                default:
                    XCTFail("Expected error to be .connectionFailed")
                }
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerConnectsWithPartialError timeout: \(error)")
            }
        }
    }
    
    func testControllerListensForSerializedMessages() throws {
        let testExpectation = expectation(description: "ConnectionController listens for messages")
        var fulfilled = false
        
        let queue = DispatchQueue(
            label: "it.airgap.beacon-sdk.test.ConnectionControllerTest.testControllerListensForSerializedMessages",
            qos: .default,
            attributes: [],
            target: .global(qos: .default)
        )
        
        let versioned = beaconVersionedRequests()
        
        let beaconConnectionMessages = versioned.enumerated().map { (index, message) in
            BeaconConnectionMessage(origin: .p2p(id: "id#\(index)"), content: message)
        }
        
        let serializedConnectionMessages = try beaconConnectionMessages.map {
            SerializedConnectionMessage(origin: $0.origin, content: try serializer.serialize(message: $0.content))
        }
        
        var received: [BeaconConnectionMessage<MockBlockchain>] = []
        initBeacon { _ in
            self.connectionController.connect { _ in
                self.connectionController.listen { (result: Result<BeaconConnectionMessage<MockBlockchain>, Error>) in
                    switch result {
                    case let .success(message):
                        queue.async(flags: .barrier) {
                            received.append(message)
                            if received.count == beaconConnectionMessages.count {
                                XCTAssertEqual(
                                    beaconConnectionMessages.sorted(by: { lhs, rhs in lhs.origin.id < rhs.origin.id }),
                                    received.sorted(by: { lhs, rhs in lhs.origin.id < rhs.origin.id }),
                                    "Expected controller to be notified with the specified messages"
                                )
                                
                                testExpectation.fulfill()
                            }
                        }
                    case let .failure(error):
                        XCTFail("Unexpected error: \(error)")
                        
                        if !fulfilled {
                            fulfilled = true
                            testExpectation.fulfill()
                        }
                    }
                }
                
                serializedConnectionMessages.enumerated().forEach { (index, message) in
                    self.transports[index % self.transports.count].notify(with: .success(message))
                }
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControlleListensForSerializedMessages timeout: \(error)")
            }
        }
    }
    
    func testControllerConnectsNewPeers() throws {
        let testExpectation = expectation(description: "ConnectionController connects new peers")
        
        let peers = p2pPeers(n: 4).map { Beacon.Peer.p2p($0) }
        
        connectionController.onNew(peers) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(
                    self.transports.reduce(true) { (acc, next) in acc && next.connectPeersCalls == [peers] },
                    "Expected all transports to call connect with the specified peers"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerConnectsNewPeers timeout: \(error)")
            }
        }
    }
    
    func testControllerDisconnectsPeers() throws {
        let testExpectation = expectation(description: "ConnectionController disconnects peers")
        
        let peers = p2pPeers(n: 4).map { Beacon.Peer.p2p($0) }
        
        connectionController.onRemoved(peers) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(
                    self.transports.reduce(true) { (acc, next) in acc && next.disconnectPeersCalls == [peers] },
                    "Expected all transports to call disconnect with the specified peers"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerDisconnectsPeers timeout: \(error)")
            }
        }
    }
    
    func testControllerSendsMessages() throws {
        let testExpectation = expectation(description: "ConnectionController sends messages")
        
        guard let versioned = beaconVersionedResponses().shuffled().first else {
            return
        }
        
        let beaconConnectionMessage = BeaconConnectionMessage(origin: .p2p(id: "id"), content: versioned)
        let serializedConnectionMessage = SerializedConnectionMessage(
            origin: beaconConnectionMessage.origin,
            content: try serializer.serialize(message: beaconConnectionMessage.content)
        )
        
        connectionController.send(beaconConnectionMessage) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(
                    self.transports.reduce(true) { (acc, next) in acc && next.sendMessageCalls == [serializedConnectionMessage] },
                    "Expected all transports to call send with the specified serialized message"
                )
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
            }
            
            testExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testControllerSendsMessages timeout: \(error)")
            }
        }
    }

    static var allTests = [
        ("testControllerConnects", testControllerConnects),
        ("testControllerConnectsWithPartialError", testControllerConnectsWithPartialError),
        ("testControllerListensForSerializedMessages", testControllerListensForSerializedMessages),
        ("testControllerConnectsNewPeers", testControllerConnectsNewPeers),
        ("testControllerDisconnectsPeers", testControllerDisconnectsPeers),
        ("testControllerSendsMessages", testControllerSendsMessages),
    ]
}
