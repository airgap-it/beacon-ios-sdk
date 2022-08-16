//
//  Consumer.swift
//  
//
//  Created by Julia Samol on 10.08.22.
//

import Foundation

public protocol BeaconConsumer {
    ///
    /// Replies to a previously received request.
    ///
    /// - Parameter response: The message to be sent in reply.
    /// - Parameter completion: The closure called when the call completes.
    /// - Parameter result: The result of the call represented as either `Void` if the call was successful or `Beacon.Error` if it failed.
    ///
    func respond<B: Blockchain>(with response: BeaconResponse<B>, completion: @escaping (_ result: Result<(), Beacon.Error>) -> ())
    
    func pair(with pairingRequest: BeaconPairingRequest, completion: @escaping (Result<BeaconPairingResponse, Beacon.Error>) -> ())
    func pair(with pairingRequest: String, completion: @escaping (Result<BeaconPairingResponse, Beacon.Error>) -> ())
}
