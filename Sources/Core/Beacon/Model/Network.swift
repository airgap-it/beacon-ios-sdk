//
//  Network.swift
//
//
//  Created by Julia Samol on 12.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol NetworkProtocol {
    var name: String? { get }
    var rpcURL: String? { get }
    
    var identifier: String { get }
}
