//
//  NodeService.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation

extension Matrix {
    
    struct NodeService: MatrixService {
        private let http: HTTP
        
        init(http: HTTP) {
            self.http = http
        }
        
        func isUp(_ node: String, completion: @escaping (Result<Bool, Swift.Error>) -> ()) {
            runCatching(completion: completion) {
                http.get(at: try apiBase(from: node, at: "/versions"), throwing: ErrorResponse.self) { (result: Result<VersionsResponse, Swift.Error>) in
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
