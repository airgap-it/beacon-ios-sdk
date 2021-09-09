//
//  MatrixForbiddenErrorResponse.swift
//  
//
//  Created by Julia Samol on 01.09.21.
//

import Foundation

extension Matrix.ErrorResponse {
    
    struct Forbidden: Codable, ErrorResponseProtocol {
        let code: String
        let error: String
        
        init(error: String) {
            code = Code.forbidden.rawValue
            self.error = error
        }
     
        enum CodingKeys: String, CodingKey {
            case code = "errcode"
            case error
        }
    }
}
