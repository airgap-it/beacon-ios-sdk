//
//  MockTime.swift
//  Mocks
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import OctezConnectCore

public struct MockTime: TimeProtocol {
    public init() {}
    
    public var currentTimeMillis: Int64 { 0 }
}
