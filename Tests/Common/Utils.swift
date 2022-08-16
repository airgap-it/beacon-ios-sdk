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
    appMetadata: AnyAppMetadata = .init(senderID: "senderID", name: "mockApp"),
    origin: Beacon.Connection.ID = .p2p(id: "senderID"),
    destination: Beacon.Connection.ID = .p2p(id: "receiverID"),
    version: String = "2"
) -> MockRequest.Permission {
    .init(
        id: id,
        version: version,
        blockchainIdentifier: MockBlockchain.identifier,
        senderID: senderID,
        appMetadata: appMetadata,
        origin: origin,
        destination: destination
    )
}

public func blockchainBeaconRequest(
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: AnyAppMetadata? = .init(senderID: "senderID", name: "mockApp"),
    signedTransaction: String = "signedTransaction",
    origin: Beacon.Connection.ID = .p2p(id: "senderID"),
    destination: Beacon.Connection.ID = .p2p(id: "receiverID"),
    version: String = "2"
) -> MockRequest.Blockchain {
    .init(
        id: id,
        version: version,
        blockchainIdentifier: MockBlockchain.identifier,
        senderID: senderID,
        origin: origin,
        destination: destination
    )
}

public func permissionBeaconResponse(
    id: String = "id",
    version: String = "2",
    destination: Beacon.Connection.ID = .p2p(id: "receiverID"),
    accountIDs: [String] = ["accountID"]
) -> MockResponse.Permission {
    .init(
        id: id,
        version: version,
        destination: destination,
        accountIDs: accountIDs
    )
}

public func blockchainBeaconResponse(
    id: String = "id",
    transactionHash: String = "transactionHash",
    version: String = "2",
    destination: Beacon.Connection.ID = .p2p(id: "receiverID")
) -> MockResponse.Blockchain {
    .init(
        id: id,
        version: version,
        destination: destination
    )
}

public func acknowledgeBeaconResponse(
    id: String = "id",
    version: String = "2",
    destination: Beacon.Connection.ID = .p2p(id: "receiverID")
) -> AcknowledgeBeaconResponse {
    .init(id: id, version: version, destination: destination)
}

public func errorBeaconResponse(
    id: String = "id",
    type: Beacon.ErrorType<MockBlockchain> = .unknown,
    version: String = "2",
    destination: Beacon.Connection.ID = .p2p(id: "receiverID")
) -> ErrorBeaconResponse<MockBlockchain> {
    .init(id: id, version: version, destination: destination, errorType: type)
}

public func disconnectBeaconMessage(
    id: String = "id",
    senderID: String = "senderID",
    version: String = "2",
    origin: Beacon.Connection.ID = .p2p(id: "senderID"),
    destination: Beacon.Connection.ID = .p2p(id: "receiverID")
) -> DisconnectBeaconMessage {
    .init(id: id, senderID: senderID, version: version, origin: origin, destination: destination)
}

public func errorBeaconResponses(id: String = "id", destination: Beacon.Connection.ID = .p2p(id: "receiverID")) -> [ErrorBeaconResponse<MockBlockchain>] {
    [
        errorBeaconResponse(id: id, type: .aborted, destination: destination),
        errorBeaconResponse(id: id, type: .unknown, destination: destination),
    ]
}

public func beaconRequests(
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: AnyAppMetadata = .init(senderID: "senderID", name: "mockApp"),
    origin: Beacon.Connection.ID = .p2p(id: "senderID"),
    version: String = "2"
) -> [BeaconRequest<MockBlockchain>] {
    [
        .permission(permissionBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
        .blockchain(blockchainBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
    ]
}

public func beaconResponses(id: String = "id", version: String = "2", destination: Beacon.Connection.ID = .p2p(id: "receiverID")) -> [BeaconResponse<MockBlockchain>] {
    [
        .permission(permissionBeaconResponse(id: id, destination: destination)),
        .blockchain(blockchainBeaconResponse(id: id, destination: destination)),
        .acknowledge(acknowledgeBeaconResponse(id: id, destination: destination)),
    ] + errorBeaconResponses(id: id, destination: destination).map { .error($0) }
}

public func beaconVersionedRequests(
    senderID: String = "senderID",
    requests: [BeaconRequest<MockBlockchain>] = beaconRequests(
        senderID: "senderID",
        appMetadata: .init(senderID: "senderID", name: "mockApp"),
        origin: .p2p(id: "senderID"),
        version: "2"
    )
) -> [VersionedBeaconMessage<MockBlockchain>] {
    requests.compactMap { try? VersionedBeaconMessage(from: .request($0), senderID: senderID) }
}

public func beaconVersionedResponses(
    senderID: String = "senderID",
    responses: [BeaconResponse<MockBlockchain>] = beaconResponses()
) -> [VersionedBeaconMessage<MockBlockchain>] {
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
