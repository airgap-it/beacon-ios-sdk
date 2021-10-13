//
//  AsyncOperation.swift
//  
//
//  Created by Julia Samol on 31.08.21.
//

import Foundation

public class AsyncOperation: Operation {
    
    public override var isAsynchronous: Bool { true }
    
    private var _isExecuting: Bool = false
    public override var isExecuting: Bool {
        get { _isExecuting }
        set {
            changeValue(forKey: .isExecuting) {
                _isExecuting = newValue
            }
        }
    }
    
    private var _isFinished: Bool = false
    public override var isFinished: Bool {
        get { _isFinished }
        set {
            changeValue(forKey: .isFinished) {
                _isFinished = newValue
            }
        }
    }
    
    fileprivate(set) var isQueued: Bool = false
    
    // MARK: Types
    
    enum Key: String {
        case isExecuting
        case isFinished
    }
}

// MARK: Extensions

private extension AsyncOperation {
    
    func willChangeValue(forKey key: AsyncOperation.Key) {
        willChangeValue(forKey: key.rawValue)
    }
    
    func didChangeValue(forKey key: AsyncOperation.Key) {
        didChangeValue(forKey: key.rawValue)
    }
    
    @inline(__always) func changeValue(forKey key: AsyncOperation.Key, _ block: () -> ()) {
        willChangeValue(forKey: key)
        block()
        didChangeValue(forKey: key)
    }
}

extension Operation {
    
    func enqueue(on queue: OperationQueue) {
        for dependency in dependencies where !dependency.isExecuting && !dependency.isFinished {
            dependency.enqueue(on: queue)
        }
        
        if let asyncOperation = self as? AsyncOperation {
            guard !asyncOperation.isQueued else { return }
            asyncOperation.isQueued = true
        }
        
        queue.addOperation(self)
    }
}
