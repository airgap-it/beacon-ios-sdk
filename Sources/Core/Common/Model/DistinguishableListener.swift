//
//  DistinguishableListener.swift
//
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class DistinguishableListener<T>: Hashable, Equatable {
    public let id: String
    private let closure: (T) -> ()
    
    public init(id: String? = nil, _ closure: @escaping (T) -> ()) {
        self.id = id ?? UUID().uuidString
        self.closure = closure
    }
    
    public static func == (lhs: DistinguishableListener, rhs: DistinguishableListener) -> Bool {
        lhs.id == rhs.id
    }
    
    public final func notify(with value: T) {
        closure(value)
    }
    
    public final func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
