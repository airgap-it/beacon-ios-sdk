//
//  LazyWeakReference.swift
//  BeaconSDK
//
//  Created by Julia Samol on 20.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class LazyWeakReference<T: AnyObject> {
    private let initializer: () -> T
    
    private weak var lazyValue: T?
    var value: T {
        guard let value = lazyValue else {
            let value = initializer()
            lazyValue = value
            
            return value
        }
        
        return value
    }
    
    init(_ initializer: @escaping () -> T) {
        self.initializer = initializer
    }
}
