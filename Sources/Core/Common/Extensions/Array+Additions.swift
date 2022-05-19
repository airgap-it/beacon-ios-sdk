//
//  Array+Additions.swift
//
//
//  Created by Julia Samol on 18.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

// MARK: Element: Any

public extension Array {
    
    func partitioned(by indices: Set<Int>) -> ([Element], [Element]) {
        var first: [Element] = []
        var second: [Element] = []
        
        enumerated().forEach { (index, element) in
            if indices.contains(index) {
                first.append(element)
            } else {
                second.append(element)
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
    
    func distinguished<Key: Hashable>(by selectKey: (Element) -> Key, mode: DistinguishMode = .keepFirst) -> [Element] {
        var dictionary = [Key: Element]()
        forEach {
            let key = selectKey($0)
            if dictionary[key] == nil || mode == .keepLast {
                dictionary[key] = $0
            }
        }
        
        return Array(dictionary.values)
    }
    
    mutating func distinguish<Key: Hashable>(by selectKey: (Element) -> Key, mode: DistinguishMode = .keepFirst) {
        self = distinguished(by: selectKey, mode: mode)
    }
    
    func distinguished(by selectKeys: (Element) -> [AnyHashable], mode: DistinguishMode = .keepFirst) -> [Element] where Element: Hashable {
        var dictionary = [Int: Element]()
        forEach {
            let key = selectKeys($0).reduce(0) { (acc, next) in acc + next.hashValue }
            if dictionary[key] == nil || mode == .keepLast {
                dictionary[key] = $0
            }
        }
        
        return Array(dictionary.values)
    }
    
    mutating func distinguish(by selectKeys: (Element) -> [AnyHashable], mode: DistinguishMode = .keepFirst) where Element: Hashable {
        self = distinguished(by: selectKeys, mode: mode)
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
                    if results[item.offset] == nil {
                        results[item.offset] = value
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(qos: .default, flags: [], queue: queue) {
            completion(results.compactMap { $0 })
        }
    }
}

// MARK: Element: Hashable

public extension Array where Element: Hashable {
    
    func distinct() -> [Element] {
        Array(Set(self))
    }
}

// MARK: Types

public enum DistinguishMode {
    case keepFirst
    case keepLast
}
