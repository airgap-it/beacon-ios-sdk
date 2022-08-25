//
//  MockAccountController.swift
//  
//
//  Created by Julia Samol on 15.08.22.
//

import Foundation
@testable import BeaconCore
@testable import BeaconClientDApp

public class MockAccountController: AccountControllerProtocol {
    private var activeAccount: PairedAccount? = nil
    private var activePeer: Beacon.Peer? = nil
    
    public init() {}
    
    public func onPairingResponse(_ pairingResponse: BeaconPairingResponse, completion: @escaping (Result<(), Error>) -> ()) {
        activePeer = pairingResponse.toPeer()
    }
    
    public func onPermissionResponse<B: Blockchain>(
        _ response: B.Response.Permission,
        ofType type: B.Type,
        origin: Beacon.Connection.ID,
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        
    }
    
    public func getActivePeer(completion: @escaping (Result<Beacon.Peer?, Error>) -> ()) {
        completion(.success(activePeer))
    }
    
    public func getActiveAccount(completion: @escaping (Result<PairedAccount?, Error>) -> ()) {
        completion(.success(activeAccount))
    }
    
    public func clearActiveAccount(completion: @escaping (Result<(), Error>) -> ()) {
        activeAccount = nil
    }
    
    public func clearAll(completion: @escaping (Result<(), Error>) -> ()) {
        activeAccount = nil
        activePeer = nil
    }
}
