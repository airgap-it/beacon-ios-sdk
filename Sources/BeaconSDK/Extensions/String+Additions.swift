//
//  String+Additions.swift
//  BeaconSDK
//
//  Created by Julia Samol on 19.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

extension String {
    
    var isHex: Bool {
        range(of: "^(\(HexString.prefix))?([0-9a-fA-F]{2})+$", options: .regularExpression) != nil
    }
    
    func substring(before separator: Character) -> String {
        String(prefix { $0 != separator })
    }
}
