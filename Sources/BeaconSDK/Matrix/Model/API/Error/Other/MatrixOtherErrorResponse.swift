//
//  MatrixOtherErrorResponse.swift
//  
//
//  Created by Julia Samol on 01.09.21.
//

import Foundation

extension Matrix.ErrorResponse {
    
    struct Other: Codable, ErrorResponseProtocol {
        let code: String
        let error: String
        
        enum CodingKeys: String, CodingKey {
            case code = "errcode"
            case error
        }
    }
}
