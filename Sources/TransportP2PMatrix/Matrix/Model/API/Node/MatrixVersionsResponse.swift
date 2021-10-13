//
//  MatrixVersionsResponse.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation

extension MatrixClient.NodeService {
    
    struct VersionsResponse: Codable {
        let versions: [String]
    }
}
