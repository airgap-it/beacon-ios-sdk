//
//  DistinguishableListener.swift
//
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class DistinguishableListener<T>: Identifiable, Hashable, Equatable {
    public let id: String
    private let closure: (DistinguishableListener<T>, T) -> ()
    
    public init(id: String? = nil, _ closure: @escaping (DistinguishableListener<T>, T) -> ()) {
        self.id = id ?? UUID().uuidString
        self.closure = closure
    }
    
    public convenience init(id: String? = nil, _ closure: @escaping (T) -> ()) {
        self.init(id: id) { (_, value) in closure(value) }
    }
    
    public static func == (lhs: DistinguishableListener, rhs: DistinguishableListener) -> Bool {
        lhs.id == rhs.id
    }
    
    public final func notify(with value: T) {
        closure(self, value)
    }
    
    public final func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
