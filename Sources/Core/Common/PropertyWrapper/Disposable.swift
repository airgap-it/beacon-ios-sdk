//
//  Disposable.swift
//  
//
//  Created by Julia Samol on 01.09.21.
//

import Foundation

@propertyWrapper public final class Disposable<T> {
    private var value: T?
    public var wrappedValue: T? {
        get {
            let value = value
            self.value = nil
            return value
        }
        set {
            value = newValue
        }
    }
    
    public init() {}
}


