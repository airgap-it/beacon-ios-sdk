//
//  Array+Additions.swift
//  BeaconSDK
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

// MARK: Element: Any

extension Array {
    
    func partitioned(by predicate: (Element) throws -> Bool) rethrows -> ([Element], [Element]) {
        var first: [Element] = []
        var second: [Element] = []
        
        try forEach {
            if try predicate($0) {
                first.append($0)
            } else {
                second.append($0)
            }
        }
        
        return (first, second)
    }
    
    func awaitAll(
        async action: @escaping (Element, @escaping (Result<(), Error>) -> ()) throws -> (),
        completion: @escaping (Result<(), Error>) -> ()
    ) {
        let queue = DispatchQueue.global(qos: .background)
        let semaphore = DispatchSemaphore(value: 1)
        var counter = 0
        
        forEach {
            do {
                try action($0) { result in
                    queue.async {
                        guard result.isSuccess(otherwise: completion) else { return }
                        semaphore.wait()
                        
                        counter += 1
                        if counter == count {
                            completion(.success(()))
                        }
                        
                        semaphore.signal()
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: Element: Hashable

extension Array where Element: Hashable {
    
    func distinct() -> [Element] {
        Array(Set(self))
    }
}
