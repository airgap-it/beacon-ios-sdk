//
//  StoreBox.swift
//  
//
//  Created by Julia Samol on 30.08.21.
//

import Foundation

open class StoreBox<S: StoreProtocol> {
    public let associated: S
    
    private lazy var queue: OperationQueue = {
       let queue = OperationQueue()
        queue.name = "Store State Queue"
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    public init(store: S) {
        self.associated = store
    }
    
    public func state(completion: @escaping (Result<S.State, Error>) -> ()) {
        let operation = StoreOperation<S.State, S>()
        
        operation.notify(completion)
        operation.async { [unowned self] in
            self.associated.state(completion: operation.stop)
        }
        
        operation.enqueue(on: queue)
    }
    
    public func intent(action: S.Action, completion: @escaping (Result<(), Error>) -> () = { _ in /* no action */ }) {
        let operation = StoreOperation<(), S>()
        
        operation.notify(completion)
        operation.async { [unowned self] in
            self.associated.intent(action: action, completion: operation.stop)
        }
        
        operation.enqueue(on: queue)
    }
    
    // MARK: Operations
    
    private class StoreOperation<T, S: StoreProtocol>: ResultOperation<T> {
        private var action: (() -> ())?
        
        func async(_ action: @escaping () -> ()) {
            self.action = action
        }
        
        override func perform() throws {
            action?()
        }
        
        override func cleanUp() {
            action = nil
        }
    }
}

public protocol StoreProtocol: AnyObject {
    associatedtype State
    associatedtype Action
    
    func state(completion: @escaping (Result<State, Swift.Error>) -> ())
    func intent(action: Action, completion: @escaping (Result<(), Swift.Error>) -> ())
}
