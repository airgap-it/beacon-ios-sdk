//
//  ErrorType.swift
//  BeaconSDK
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension Beacon {
    
    public enum ErrorType: String, Codable {
        case broadcastError = "BROADCAST_ERROR"
        case networkNotSupported = "NETWORK_NOT_SUPPORTED_ERROR"
        case noAddressError = "NO_ADDRESS_ERROR"
        case noPrivateKeyFound = "NO_PRIVATE_KEY_FOUND_ERROR"
        case notGranted = "NOT_GRANTED_ERROR"
        case parametersInvalid = "PARAMETERS_INVALID_ERROR"
        case tooManyOperations = "TOO_MANY_OPERATIONS_ERROR"
        case transactionInvalid = "TRANSACTION_INVALID_ERROR"
        case aborted = "ABORTED_ERROR"
        case unknown = "UNKNOWN_ERROR"
    }
}
