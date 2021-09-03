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
    
    func grouped<Key: Hashable>(by selectKey: (Element) -> Key) -> [Key: Element] {
        var dictionary = [Key: Element]()
        forEach { dictionary[selectKey($0)] = $0 }
        
        return dictionary
    }
    
    func grouped<Key: Hashable>(by selectKey: (Element) -> Key) -> [Key: [Element]] {
        var dictionary = [Key: [Element]]()
        forEach {
            let key = selectKey($0)
            let elements = dictionary[key] ?? [Element]()
            dictionary[key] = elements + [$0]
        }
        
        return dictionary
    }
    
    func shifted(by offset: Int) -> [Element] {
        let offset = offset % count
        return Array(self[offset...] + self[0..<offset])
    }
    
    func forEachAsync<T>(
        with group: DispatchGroup = .init(),
        body: @escaping (Element, @escaping (T) -> ()) -> (),
        completion: @escaping ([T]) -> ()
    ) {
        var results = [T?](repeating: nil, count: count)
        let queue = DispatchQueue(label: "it.airgap.beacon-sdk.forEachAsync", qos: .default, attributes: [], target: .global(qos: .default))
        
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
