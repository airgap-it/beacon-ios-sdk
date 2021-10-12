//
//  Utils.swift
//  Common
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import XCTest

@testable import BeaconCore

// MARK: Setup

public func initBeacon(
    appName: String = "mockApp",
    appIcon: String? = nil,
    appURL: String? = nil,
    dependencyRegistry: DependencyRegistry = MockDependencyRegistry(),
    completion: @escaping (Result<Beacon, Swift.Error>) -> () = { _ in }
) {
    Beacon.initialize(appName: appName, appIcon: appIcon, appURL: appURL, dependencyRegistry: dependencyRegistry, completion: completion)
}

public func clearBeacon() {
    Beacon.reset()
}

// MARK: Functions

public func runAsync(with group: DispatchGroup = .init(), times n: Int, body: @escaping (@escaping () -> ()) -> (), completion: @escaping () -> ()) {
    let queue = DispatchQueue(label: "it.airgap.beacon-sdk-tests.runAsync", qos: .default, attributes: [], target: .global(qos: .default))
    
    for _ in 0..<n {
        group.enter()
        body {
            group.leave()
        }
    }
    
    group.notify(qos: .default, flags: [], queue: queue) {
        completion()
    }
}

// MARK: Factories

public func permissionBeaconRequest(
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata = .init(senderID: "senderID", name: "mockApp"),
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> MockRequest.Permission {
    .init(
        appMetadata: appMetadata,
        blockchainIdentifier: MockBlockchain.identifier,
        senderID: senderID,
        origin: origin,
        id: id,
        version: version
    )
}

public func blockchainBeaconRequest(
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata? = .init(senderID: "senderID", name: "mockApp"),
    signedTransaction: String = "signedTransaction",
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> MockRequest.Blockchain {
    .init(
        blockchainIdentifier: MockBlockchain.identifier,
        senderID: senderID,
        origin: origin,
        id: id,
        version: version
    )
}

public func permissionBeaconResponse(
    id: String = "id",
    publicKey: String = "publicKey",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID"),
    threshold: Beacon.Threshold? = nil
) -> MockResponse.Permission {
    .init(
        blockchainIdentifier: MockBlockchain.identifier,
        publicKey: publicKey,
        threshold: threshold,
        requestOrigin: requestOrigin,
        id: id,
        version: version
    )
}

public func blockchainBeaconResponse(
    id: String = "id",
    transactionHash: String = "transactionHash",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> MockResponse.Blockchain {
    .init(
        blockchainIdentifier: MockBlockchain.identifier,
        requestOrigin: requestOrigin,
        id: id,
        version: version
    )
}

public func acknowledgeBeaconResponse(
    id: String = "id",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> AcknowledgeBeaconResponse {
    .init(id: id, version: version, requestOrigin: requestOrigin)
}

public func errorBeaconResponse(
    id: String = "id",
    type: Beacon.ErrorType<MockBlockchain> = .unknown,
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> ErrorBeaconResponse<MockBlockchain> {
    .init(id: id, errorType: type, version: version, requestOrigin: requestOrigin)
}

public func disconnectBeaconMessage(
    id: String = "id",
    senderID: String = "senderID",
    version: String = "2",
    origin: Beacon.Origin = .p2p(id: "senderID")
) -> DisconnectBeaconMessage {
    .init(id: id, senderID: senderID, version: version, origin: origin)
}

public func errorBeaconResponses(id: String = "id", requestOrigin: Beacon.Origin = .p2p(id: "senderID")) -> [ErrorBeaconResponse<MockBlockchain>] {
    [
        errorBeaconResponse(id: id, type: .aborted, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .unknown, requestOrigin: requestOrigin),
    ]
}

public func beaconRequests(
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata = .init(senderID: "senderID", name: "mockApp"),
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> [BeaconRequest<MockBlockchain>] {
    [
        .permission(permissionBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
        .blockchain(blockchainBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
    ]
}

public func beaconResponses(id: String = "id", version: String = "2", requestOrigin: Beacon.Origin = .p2p(id: "senderID")) -> [BeaconResponse<MockBlockchain>] {
    [
        .permission(permissionBeaconResponse(id: id, requestOrigin: requestOrigin)),
        .blockchain(blockchainBeaconResponse(id: id, requestOrigin: requestOrigin)),
        .acknowledge(acknowledgeBeaconResponse(id: id, requestOrigin: requestOrigin)),
    ] + errorBeaconResponses(id: id, requestOrigin: requestOrigin).map { .error($0) }
}

public func beaconVersionedRequests(
    senderID: String = "senderID",
    requests: [BeaconRequest<MockBlockchain>] = beaconRequests(
        senderID: "senderID",
        appMetadata: .init(senderID: "senderID", name: "mockApp"),
        origin: .p2p(id: "senderID"),
        version: "2"
    )
) -> [VersionedBeaconMessage] {
    requests.compactMap { try? VersionedBeaconMessage(from: .request($0), senderID: senderID) }
}

public func beaconVersionedResponses(
    senderID: String = "senderID",
    responses: [BeaconResponse<MockBlockchain>] = beaconResponses()
) -> [VersionedBeaconMessage] {
    responses.compactMap { try? VersionedBeaconMessage(from: .response($0), senderID: senderID) }
}

public func p2pPeers(n: Int, version: String = "1") -> [Beacon.P2PPeer] {
    (0..<n).map {
        Beacon.P2PPeer(
            name: "name#\($0)",
            publicKey: "publicKey#\($0)",
            relayServer: "relayServer#\($0)",
            version: version
        )
    }
}
