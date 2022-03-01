//
//  NodeService.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation
import BeaconCore

extension MatrixClient {
    
    class NodeService: MatrixService {
        
        // MARK: API Calls
        
        func isUp(_ node: String, completion: @escaping (Result<Bool, Swift.Error>) -> ()) {
            runCatching(completion: completion) {
                let url = try apiBase(from: node, at: "/versions")
                let call = OngoingCall(method: .get, url: url)
                addOngoing(call)
                
                http.get(at: url, throwing: ErrorResponse.self) { (result: Result<VersionsResponse, Swift.Error>) in
                    self.removeOngoing(call)
                    switch result {
                    case .success(_):
                        completion(.success(true))
                    case .failure(_):
                        completion(.success(false))
                    }
                }
            }
        }
    }
}
