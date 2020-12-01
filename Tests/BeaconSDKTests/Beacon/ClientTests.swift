//
//  ClientTests.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import XCTest
@testable import BeaconSDK

class ClientTests: XCTestCase {
    
    private var beaconClient: Beacon.Client!
    private var storage: MockStorage!
    private var storageManager: StorageManager!
    private var connectionController: MockConnectionController!
    private var messageController: MockMessageController!
    
    private let dAppVersion: String = "2"
    private let dAppID: String = "dAppID"
    private let beaconID: String = "beaconID"
    
    override func setUpWithError() throws {
        storage = MockStorage()
        storageManager = StorageManager(storage: storage)
        
        connectionController = MockConnectionController()
        messageController = MockMessageController(storage: storageManager)
        
        beaconClient = Beacon.Client(
            name: "mockApp",
            beaconID: beaconID,
            storage: storageManager,
            connectionController: connectionController,
            messageController: messageController
        )
    }
    
    override func tearDownWithError() throws {
        beaconClient = nil
        messageController = nil
        connectionController = nil
        storageManager = nil
        storage = nil
    }
    
    func testBeaconClientListensForRequests() {
        let expect = expectation(description: "BeaconClient connect")
        
        let appMetadata = Beacon.AppMetadata(senderID: dAppID, name: "mockApp")
        storage.set([appMetadata]) { _ in }
        
        let origin = Beacon.Origin.p2p(id: dAppID)
        
        let requests = beaconRequests(senderID: dAppID, appMetadata: appMetadata, origin: origin)
        let versioned = beaconVersionedRequests(senderID: dAppID, requests: requests).map { (origin, $0) }
        connectionController.register(messages: versioned)
        
        var received: [Beacon.Request] = []
        beaconClient.listen { result in
            switch result {
            case let .success(request):
                received.append(request)
                if received.count == versioned.count {
                    XCTAssertEqual(requests, received, "Received requests don't match expected")
                    expect.fulfill()
                }
            case let .failure(error):
                XCTFail("Unexpected error: \(error)")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("testBeaconClientListensForRequests timeout: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("testBeaconClientListensForRequests", testBeaconClientListensForRequests)
    ]
}
