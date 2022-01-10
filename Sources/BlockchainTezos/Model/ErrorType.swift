//
//  ErrorType.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation
import BeaconCore

extension Tezos {
    
    /// Types of Tezos errors supported in Beacon.
    public enum ErrorType: String, ErrorTypeProtocol, Codable {
        
        ///
        /// Indicates that the transaction broadcast failed.
        ///
        /// Applicable to `OperationTezosRequest` and `BroadcastTezosRequest`.
        ///
        case broadcastError = "BROADCAST_ERROR"
        
        ///
        /// Indicates that the specified network is not supported by the wallet.
        ///
        /// Applicable to `PermissionTezosRequest`.
        ///
        case networkNotSupported = "NETWORK_NOT_SUPPORTED_ERROR"
        
        ///
        /// Indicates that there is no address present for the protocol or specified network.
        ///
        /// Applicable to `PermissionTezosRequest`.
        ///
        case noAddressError = "NO_ADDRESS_ERROR"
        
        ///
        ///Indicates that a private key matching the address provided in the request could not be found.
        ///
        /// Applicable to `SignPayloadTezosRequest`.
        ///
        case noPrivateKeyFound = "NO_PRIVATE_KEY_FOUND_ERROR"
        
        ///
        /// Indicates that the signature was blocked and could not be completed (`SignPayloadTezosRequest`)
        /// or the permissions requested by the dApp were rejected (`PermissionTezosRequest`).
        ///
        /// Applicable to `SignPayloadTezosRequest` and `PermissionTezosRequest`.
        ///
        case notGranted = "NOT_GRANTED_ERROR"
        
        ///
        /// Indicates that any of the provided parameters are invalid.
        ///
        /// Applicable to `OperationTezosRequest`.
        ///
        case parametersInvalid = "PARAMETERS_INVALID_ERROR"
        
        ///
        /// Indicates that too many operation details were included in the request
        /// and they could not be included into a single operation group.
        ///
        /// Applicable to `OperationTezosRequest`.
        ///
        case tooManyOperations = "TOO_MANY_OPERATIONS_ERROR"
        
        ///
        /// Indicates that the transaction included in the request could not be parsed or was rejected by the node.
        ///
        /// Applicable to `BroadcastTezosRequest`.
        ///
        case transactionInvalid = "TRANSACTION_INVALID_ERROR"
        
        ///
        /// Indicates that the requested type of signature is not supported in the client.
        ///
        /// Applicable to `SignPayloadTezosRequest`.
        ///
        case signatureTypeNotSupported = "SIGNATURE_TYPE_NOT_SUPPORTED"
        
        public var blockchainIdentifier: String? { Tezos.identifier }
    }
}
