//
//  LazyWeakReference.swift
//
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class LazyWeakReference<T: AnyObject> {
    private let initializer: () -> T
    
    private weak var lazyValue: T?
    public var value: T {
        guard let value = lazyValue else {
            let value = initializer()
            lazyValue = value
            
            return value
        }
        
        return value
    }
    
    public init(_ initializer: @escaping () -> T) {
        self.initializer = initializer
    }
}

public class ThrowingLazyWeakReference<T: AnyObject> {
    private let initializer: () throws -> T
    
    private weak var lazyValue: T?
    public func value() throws -> T {
        guard let value = lazyValue else {
            let value = try initializer()
            lazyValue = value
            
            return value
        }
        
        return value
    }
    
    public init(_ initializer: @escaping () throws -> T) {
        self.initializer = initializer
    }
}
