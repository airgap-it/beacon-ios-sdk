//
//  BlockchainCreator.swift
//  
//
//  Created by Julia Samol on 01.10.21.
//

import Foundation

public protocol BlockchainCreator {
    associatedtype ConcreteBlockchain: Blockchain
    
    func extractPermission(
        from request: ConcreteBlockchain.Request.Permission,
        and response: ConcreteBlockchain.Response.Permission,
        completion: @escaping (Result<[ConcreteBlockchain.Permission], Swift.Error>) -> ()
    )
}
