//
//  DistinguishableListener.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class DistinguishableListener<T>: Hashable, Equatable {
    private let id: Int
    private let closure: (T) -> ()
    
    init(_ closure: @escaping (T) -> ()) {
        id = UUID.init().hashValue
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
