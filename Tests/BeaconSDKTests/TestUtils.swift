//
//  TestUtils.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

// MARK: Functions

func runAsync(with group: DispatchGroup = .init(), times n: Int, body: @escaping (@escaping () -> ()) -> (), completion: @escaping () -> ()) {
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

func permissionBeaconRequest(
    type: String = "permission_request",
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata = .init(senderID: "senderID", name: "mockApp"),
    network: Beacon.Network = .init(type: .custom),
    scopes: [Beacon.Permission.Scope] = [],
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> Beacon.Request.Permission {
    Beacon.Request.Permission(
        type: type,
        id: id,
        senderID: senderID,
        appMetadata: appMetadata,
        network: network,
        scopes: scopes,
        origin: origin,
        version: version
    )
}

func operationBeaconRequest(
    type: String = "operation_request",
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata? = .init(senderID: "senderID", name: "mockApp"),
    network: Beacon.Network = .init(type: .custom),
    operationDetails: [Tezos.Operation] = [],
    sourceAddress: String = "sourceAddress",
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> Beacon.Request.Operation {
    Beacon.Request.Operation(
        type: type,
        id: id,
        senderID: senderID,
        appMetadata: appMetadata,
        network: network,
        operationDetails: operationDetails,
        sourceAddress: sourceAddress,
        origin: origin,
        version: version
    )
}

func signPayloadBeaconRequest(
    type: String = "sign_payload_request",
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata? = .init(senderID: "senderID", name: "mockApp"),
    signingType: Beacon.SigningType = .raw,
    payload: String = "payload",
    sourceAddress: String = "sourceAddress",
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> Beacon.Request.SignPayload {
    Beacon.Request.SignPayload(
        type: type,
        id: id,
        senderID: senderID,
        appMetadata: appMetadata,
        signingType: signingType,
        payload: payload,
        sourceAddress: sourceAddress,
        origin: origin,
        version: version
    )
}

func broadcastBeaconRequest(
    type: String = "broadcast_request",
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata? = .init(senderID: "senderID", name: "mockApp"),
    network: Beacon.Network = .init(type: .custom),
    signedTransaction: String = "signedTransaction",
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> Beacon.Request.Broadcast {
    Beacon.Request.Broadcast(
        type: type,
        id: id,
        senderID: senderID,
        appMetadata: appMetadata,
        network: network,
        signedTransaction: signedTransaction,
        origin: origin,
        version: version
    )
}

func permissionBeaconResponse(
    id: String = "id",
    publicKey: String = "publicKey",
    network: Beacon.Network = .init(type: .custom),
    scopes: [Beacon.Permission.Scope] = [],
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Response.Permission {
    Beacon.Response.Permission(id: id, publicKey: publicKey, network: network, scopes: scopes, version: version, requestOrigin: requestOrigin)
}

func operationBeaconResponse(
    id: String = "id",
    transactionHash: String = "transactionHash",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Response.Operation {
    Beacon.Response.Operation(id: id, transactionHash: transactionHash, version: version, requestOrigin: requestOrigin)
}

func signPayloadBeaconResponse(
    id: String = "id",
    signingType: Beacon.SigningType = .raw,
    signature: String = "signature",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Response.SignPayload {
    Beacon.Response.SignPayload(id: id, signingType: signingType, signature: signature, version: version, requestOrigin: requestOrigin)
}

func broadcastBeaconResponse(
    id: String = "id",
    transactionHash: String = "transactionHash",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Response.Broadcast {
    Beacon.Response.Broadcast(id: id, transactionHash: transactionHash, version: version, requestOrigin: requestOrigin)
}

func acknowledgeBeaconResponse(
    id: String = "id",
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Response.Acknowledge {
    Beacon.Response.Acknowledge(id: id, version: version, requestOrigin: requestOrigin)
}

func errorBeaconResponse(
    id: String = "id",
    type: Beacon.ErrorType = .unknown,
    version: String = "2",
    requestOrigin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Response.Error {
    Beacon.Response.Error(id: id, errorType: type, version: version, requestOrigin: requestOrigin)
}

func disconnectBeaconMessage(
    id: String = "id",
    senderID: String = "senderID",
    version: String = "2",
    origin: Beacon.Origin = .p2p(id: "senderID")
) -> Beacon.Message.Disconnect {
    Beacon.Message.Disconnect(id: id, senderID: senderID, version: version, origin: origin)
}

func errorBeaconResponses(id: String = "id", requestOrigin: Beacon.Origin = .p2p(id: "senderID")) -> [Beacon.Response.Error] {
    [
        errorBeaconResponse(id: id, type: .broadcastError, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .networkNotSupported, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .noAddressError, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .noPrivateKeyFound, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .notGranted, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .parametersInvalid, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .tooManyOperations, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .transactionInvalid, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .signatureTypeNotSupported, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .aborted, requestOrigin: requestOrigin),
        errorBeaconResponse(id: id, type: .unknown, requestOrigin: requestOrigin),
    ]
}

func beaconRequests(
    id: String = "id",
    senderID: String = "senderID",
    appMetadata: Beacon.AppMetadata = .init(senderID: "senderID", name: "mockApp"),
    origin: Beacon.Origin = .p2p(id: "senderID"),
    version: String = "2"
) -> [Beacon.Request] {
    [
        .permission(permissionBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
        .operation(operationBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
        .signPayload(signPayloadBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
        .broadcast(broadcastBeaconRequest(id: id, senderID: senderID, appMetadata: appMetadata, origin: origin)),
    ]
}

func beaconResponses(id: String = "id", version: String = "2", requestOrigin: Beacon.Origin = .p2p(id: "senderID")) -> [Beacon.Response] {
    [
        .permission(permissionBeaconResponse(id: id, requestOrigin: requestOrigin)),
        .operation(operationBeaconResponse(id: id, requestOrigin: requestOrigin)),
        .signPayload(signPayloadBeaconResponse(id: id, requestOrigin: requestOrigin)),
        .acknowledge(acknowledgeBeaconResponse(id: id, requestOrigin: requestOrigin)),
        .broadcast(broadcastBeaconResponse(id: id, requestOrigin: requestOrigin)),
    ] + errorBeaconResponses(id: id, requestOrigin: requestOrigin).map { .error($0) }
}

func beaconVersionedRequests(
    senderID: String = "senderID",
    requests: [Beacon.Request] = beaconRequests(
        senderID: "senderID",
        appMetadata: .init(senderID: "senderID", name: "mockApp"),
        origin: .p2p(id: "senderID"),
        version: "2"
    )
) -> [Beacon.Message.Versioned] {
    requests.compactMap { try? Beacon.Message.Versioned(from: .request($0), senderID: senderID) }
}

func beaconVersionedResponses(
    senderID: String = "senderID",
    responses: [Beacon.Response] = beaconResponses()
) -> [Beacon.Message.Versioned] {
    responses.compactMap { try? Beacon.Message.Versioned(from: .response($0), senderID: senderID) }
}

func p2pPeers(n: Int, version: String = "1") -> [Beacon.P2PPeer] {
    (0..<n).map {
        Beacon.P2PPeer(
            name: "name#\($0)",
            publicKey: "publicKey#\($0)",
            relayServer: "relayServer#\($0)",
            version: version
        )
    }
}
