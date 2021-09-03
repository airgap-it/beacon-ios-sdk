//
//  MatrixErrorResponse.swift
//  
//
//  Created by Julia Samol on 01.09.21.
//

import Foundation

extension Matrix {
    
    enum ErrorResponse: Codable, Swift.Error {
        case forbidden(Forbidden)
        case other(Other)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let code = try? container.decode(Code.self, forKey: .code)
            switch code {
            case .forbidden:
                self = .forbidden(try Forbidden(from: decoder))
            default:
                self = .other(try Other(from: decoder))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            switch self {
            case let .forbidden(content):
                try content.encode(to: encoder)
            case let .other(content):
                try content.encode(to: encoder)
            }
        }
        
        // MARK: Attributes
        
        var common: ErrorResponseProtocol {
            switch self {
            case let .forbidden(content):
                return content
            case let .other(content):
                return content
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case code = "errcode"
        }
        
        enum Code: String, Codable {
            case forbidden = "M_FORBIDDEN"
        }
    }
}

// MARK: Protocol

protocol ErrorResponseProtocol {
    var code: String { get }
    var error: String { get }
}
