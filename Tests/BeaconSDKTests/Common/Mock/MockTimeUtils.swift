//
//  MockTimeUtils.swift
//  BeaconSDKTests
//
//  Created by Julia Samol on 01.12.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
@testable import BeaconSDK

class MockTimeUtils: TimeUtilsProtocol {
    var currentTimeMillis: Int64 { 0 }
}
