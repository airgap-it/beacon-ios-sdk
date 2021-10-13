//
//  ResultOperation.swift
//  
//
//  Created by Julia Samol on 31.08.21.
//

import Foundation

public class ResultOperation<T>: AsyncOperation {
    private var result: ResultState<T> = .pending
    private var completionHandlers: [(Result<T, Swift.Error>) -> ()] = []
    
    override init() {
        super.init()
        completionBlock = { [unowned self] in
            if let result = self.result.unwrap() {
                self.completionHandlers.forEach { $0(result) }
            }
            self.completionHandlers.removeAll()
            self.cleanUp()
        }
    }
    
    public override func start() {
        guard !isCancelled else { return }
        
        isExecuting = true
        
        do {
            try perform()
        } catch {
            stop(with: .failure(error))
        }
    }
    
    public override func cancel() {
        super.cancel()
        stop(with: .failure(Error.cancelled))
    }
    
    public func stop(with result: Result<T, Swift.Error>) {
        self.result = .finished(result)
        self.isExecuting = false
        self.isFinished = true
    }
    
    public func notify(_ completion: @escaping (Result<T, Swift.Error>) -> ()) {
        completionHandlers.append(completion)
    }
    
    public func perform() throws {}
    public func cleanUp() {}
    
    // MARK: Types
    
    enum ResultState<T> {
        case pending
        case finished(Result<T, Swift.Error>)
    }
    
    enum Error: Swift.Error {
        case cancelled
    }
}

// MARK: Extensions

private extension ResultOperation.ResultState {
    
    func unwrap() -> Result<T, Swift.Error>? {
        switch self {
        case let .finished(result):
            return result
        default:
            return nil
        }
    }
}
