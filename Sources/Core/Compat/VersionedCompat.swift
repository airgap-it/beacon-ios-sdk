//
//  VersionedCompat.swift
//  
//
//  Created by Julia Samol on 08.10.21.
//

import Foundation

public protocol VersionedCompat {
    var withVersion: String { get }
    
    func blockchain() throws -> ShadowBlockchain
}
