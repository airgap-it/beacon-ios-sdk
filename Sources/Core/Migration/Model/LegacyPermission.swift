//
//  LegacyPermission.swift
//  
//
//  Created by Julia Samol on 03.02.22.
//

import Foundation

public protocol LegacyPermissionProtocol: PermissionProtocol {
    static var fromVersion: String { get }
}
