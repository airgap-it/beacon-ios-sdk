//
//  SingleCall.swift
//  BeaconSDK
//
//  Created by Julia Samol on 26.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
class SingleCall<T> {
    private var completions: [Completion<T>]?
    private let queue: DispatchQueue = .init(
        label: "it.airgap.beacon-sdk.CachedCompletion",
        qos: .default,
        attributes: [],
        target: .global(qos: .default)
    )
    
    func run(
        body: @escaping (@escaping Completion<T>) -> (),
        onResult completion: @escaping Completion<T>,
        callback: @escaping () -> () = {}
    ) {
        queue.async {
            if self.completions?.append(completion) == nil {
                self.completions = [completion]
                body { [weak self] result in
                    self?.queue.async {
                        guard let cached = self?.completions else { return }
                        self?.completions = nil
                        cached.forEach { $0(result) }
                    }
                }
            }
            callback()
        }
    }
    
    typealias Completion<T> = (Result<T, Swift.Error>) -> ()
}
