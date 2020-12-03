//
//  ErrorType.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    /// Types of errors supported in the Beacon connection.
    public enum ErrorType: String, Codable {
        
        ///
        /// Indicates that the transaction broadcast failed.
        ///
        /// Applicable to `Beacon.Request.operation` and `Beacon.Request.broadcast`.
        ///
        case broadcastError = "BROADCAST_ERROR"
        
        ///
        /// Indicates that the specified network is not supported by the wallet.
        ///
        /// Applicable to `Beacon.Request.permission`.
        ///
        case networkNotSupported = "NETWORK_NOT_SUPPORTED_ERROR"
        
        ///
        /// Indicates that there is no address present for the protocol or specified network.
        ///
        /// Applicable to `Beacon.Request.permission`.
        ///
        case noAddressError = "NO_ADDRESS_ERROR"
        
        ///
        ///Indicates that a private key matching the address provided in the request could not be found.
        ///
        /// Applicable to `Beacon.Request.signPayload`.
        ///
        case noPrivateKeyFound = "NO_PRIVATE_KEY_FOUND_ERROR"
        
        ///
        /// Indicates that the signature was blocked and could not be completed (`Beacon.Request.signPayload`)
        /// or the permissions requested by the dApp were rejected (`Beacon.Request.permission`).
        ///
        /// Applicable to `Beacon.Request.signPayload` and `Beacon.Request.permission`.
        ///
        case notGranted = "NOT_GRANTED_ERROR"
        
        ///
        /// Indicates that any of the provided parameters are invalid.
        ///
        /// Applicable to `Beacon.Request.operation`.
        ///
        case parametersInvalid = "PARAMETERS_INVALID_ERROR"
        
        ///
        /// Indicates that too many operation details were included in the request
        /// and they could not be included into a single operation group.
        ///
        /// Applicable to `Beacon.Request.operation`.
        ///
        case tooManyOperations = "TOO_MANY_OPERATIONS_ERROR"
        
        ///
        /// Indicates that the transaction included in the request could not be parsed or was rejected by the node.
        ///
        /// Applicable to `Beacon.Request.broadcast`.
        ///
        case transactionInvalid = "TRANSACTION_INVALID_ERROR"
        
        ///
        /// Indicates that the request execution has been aborted by the user or the wallet.
        ///
        /// Applicable to every `Beacon.Request`.
        ///
        case aborted = "ABORTED_ERROR"
        
        ///
        /// Indicates that an unexpected error occurred.
        ///
        /// Applicable to every `Beacon.Request`.
        ///
        case unknown = "UNKNOWN_ERROR"
    }
}
