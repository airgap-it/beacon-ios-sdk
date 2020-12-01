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
    
    func unzip<T, U>() -> (Array<T>, Array<U>) where Element == (T, U) {
        var unzipped = ([T](), [U]())
        
        unzipped.0.reserveCapacity(count)
        unzipped.1.reserveCapacity(count)
        
        return reduce(into: unzipped) { acc, pair in
            acc.0.append(pair.0)
            acc.1.append(pair.1)
        }
    }
    
    func forEachAsync(
        with group: DispatchGroup = .init(),
        body: @escaping (Element, @escaping (Result<(), Error>) -> ()) throws -> (),
        completion: @escaping ([Result<(), Error>]) -> ()
    ) {
        var results: [Result<(), Error>] = map { _ in .success(()) }
        let queue = DispatchQueue(label: "it.airgap.beacon-sdk.forEachAsync_result", qos: .default, attributes: [], target: .global(qos: .default))
        
        func save(error: Error, at index: Int) {
            queue.async {
                results[index] = .failure(error)
                group.leave()
            }
        }
        
        for item in self.enumerated() {
            group.enter()
            do {
                try body(item.element) { result in
                    switch result {
                    case .success(_):
                        group.leave()
                    case let .failure(error):
                        save(error: error, at: item.offset)
                    }
                }
            } catch {
                save(error: error, at: item.offset)
            }
        }
        
        group.notify(qos: .default, flags: [], queue: queue) {
            completion(results)
        }
    }
    
    func forEachAsync<T>(
        with group: DispatchGroup = .init(),
        body: @escaping (Element, @escaping (T) -> ()) -> (),
        completion: @escaping ([T]) -> ()
    ) {
        var results = [T?](repeating: nil, count: count)
        let queue = DispatchQueue(label: "it.airgap.beacon-sdk.forEachAsync_value", qos: .default, attributes: [], target: .global(qos: .default))
        
        for item in self.enumerated() {
            group.enter()
            body(item.element) { value in
                queue.async {
                    results[item.offset] = value
                    group.leave()
                }
            }
        }
        
        group.notify(qos: .default, flags: [], queue: queue) {
            completion(results.compactMap { $0 })
        }
    }
}

// MARK: Element: Hashable

extension Array where Element: Hashable {
    
    func distinct() -> [Element] {
        Array(Set(self))
    }
}
