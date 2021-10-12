//
//  Poller.swift
//  
//
//  Created by Julia Samol on 06.09.21.
//

import Foundation

public class Poller<T> {
    private var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Poller"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var guardQueue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.Poller.guard", attributes: [], target: .global(qos: .default))
    private var schedulerQueue: DispatchQueue = .init(label: "it.airgap.beacon-sdk.Poller.scheduler", attributes: [], target: .global(qos: .default))
    
    private(set) var status: Status = .idle
    private let action: (@escaping (Result<T, Swift.Error>) -> ()) -> ()
    
    public init(action: @escaping (@escaping (Result<T, Swift.Error>) -> ()) -> ()) {
        self.action = action
    }
    
    public func run(
        every interval: DispatchTimeInterval,
        onResult callback: @escaping (Result<T, Swift.Error>, @escaping (Result<(), Swift.Error>) -> ()) -> ()
    ) {
        guard self.status == .idle else { return }
        
        self.status = .running
        self.schedule(every: interval, onResult: callback)
    }
    
    private func schedule(
        every interval: DispatchTimeInterval,
        onResult callback: @escaping Callback
    ) {
        guardQueue.async {
            guard self.status != .cancelled else { return }
            
            let operation: PollerOperation<T> = .init()
            operation.notify { [weak self] actionResult in
                let continuation = { [weak self] (continuationResult: Result<(), Swift.Error>) in
                    guard continuationResult.isSuccess else { return }
                    
                    self?.schedulerQueue.asyncAfter(deadline: .now() + interval) { [weak self] in
                        self?.schedule(every: interval, onResult: callback)
                    }
                }
                
                switch actionResult {
                case .success(_):
                    callback(actionResult, continuation)
                case let .failure(error):
                    guard !error.isCancelled(forType: T.self) else { return }
                    callback(actionResult, continuation)
                }
                
            }
            operation.async { [weak self] in self?.action(operation.stop) }
            operation.enqueue(on: self.queue)
        }
    }
    
    public func cancel(completion: @escaping () -> () = {}) {
        guardQueue.async {
            self.queue.isSuspended = true
            self.queue.cancelAllOperations()
            self.status = .cancelled
            
            completion()
        }
    }
    
    public func suspend(completion: @escaping () -> () = {}) {
        guardQueue.async {
            guard self.status == .running else {
                completion()
                return
            }
            
            self.queue.isSuspended = true
            self.status = .suspended
            
            completion()
        }
    }
    
    public func resume(completion: @escaping () -> () = {}) {
        guardQueue.async {
            guard self.status == .suspended else {
                completion()
                return
            }
            
            self.status = .running
            self.queue.isSuspended = false
            
            completion()
        }
    }
    
    // MARK: Types
    
    private class PollerOperation<T>: ResultOperation<T> {
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
    
    typealias Callback = (Result<T, Swift.Error>, @escaping (Result<(), Swift.Error>) -> ()) -> ()
    
    enum Status {
        case idle
        case running
        case suspended
        case cancelled
    }
}

// MARK: Extensions

private extension Swift.Error {
    func isCancelled<T>(forType type: T.Type) -> Bool {
        guard let operationError = self as? ResultOperation<T>.Error else {
            return false
        }
        
        switch operationError {
        case .cancelled:
            return true
        }
    }
}
