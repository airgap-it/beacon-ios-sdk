//
//  DistinguishableListener.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class DistinguishableListener<T>: Hashable, Equatable {
    let id: String
    private let closure: (T) -> ()
    
    init(id: String? = nil, _ closure: @escaping (T) -> ()) {
        self.id = id ?? UUID().uuidString
        self.closure = closure
    }
    
    static func == (lhs: DistinguishableListener, rhs: DistinguishableListener) -> Bool {
        lhs.id == rhs.id
    }
    
    final func on(value: T) {
        closure(value)
    }
    
    final func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
