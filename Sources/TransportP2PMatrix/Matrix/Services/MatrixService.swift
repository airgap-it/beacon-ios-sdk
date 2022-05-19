//
//  MatrixService.swift
//  
//
//  Created by Julia Samol on 26.08.21.
//

import Foundation
import BeaconCore
    
class MatrixService {
    let http: HTTP
    
    private var ongoingCalls: Set<OngoingCall> = []
    private let ongoingTasksQueue: DispatchQueue = .init(
        label: "it.airgap.beacon-sdk.MatrixService.ongoingTasks",
        qos: .default,
        attributes: [],
        target: .global(qos: .default)
    )
    
    init(http: HTTP) {
        self.http = http
    }
    
    // MARK: Call Management
    
    func addOngoing(_ call: OngoingCall) {
        ongoingTasksQueue.async {
            self.ongoingCalls.insert(call)
        }
    }
    
    func removeOngoing(_ call: OngoingCall) {
        ongoingTasksQueue.async {
            self.ongoingCalls.remove(call)
        }
    }
    
    func cancel(for node: String) {
        ongoingTasksQueue.async {
            for call in self.ongoingCalls where call.url.host == node {
                self.http.cancelTasks(for: call.url, and: call.method)
                self.ongoingCalls.remove(call)
            }
        }
    }
    
    func cancelAll() {
        ongoingTasksQueue.async {
            for call in self.ongoingCalls {
                self.http.cancelTasks(for: call.url, and: call.method)
            }
            self.ongoingCalls.removeAll()
        }
    }
    
    func suspend(for node: String) {
        ongoingTasksQueue.async {
            for call in self.ongoingCalls where call.url.host == node {
                self.http.suspendTasks(for: call.url, and: call.method)
            }
        }
    }
    
    func suspendAll() {
        ongoingTasksQueue.async {
            for call in self.ongoingCalls {
                self.http.suspendTasks(for: call.url, and: call.method)
            }
        }
    }
    
    func resume(for node: String) {
        ongoingTasksQueue.async {
            for call in self.ongoingCalls where call.url.host == node {
                self.http.resumeTasks(for: call.url, and: call.method)
            }
        }
    }
    
    func resumeAll() {
        ongoingTasksQueue.async {
            for call in self.ongoingCalls {
                self.http.resumeTasks(for: call.url, and: call.method)
            }
        }
    }
    
    // MARK: URL
    
    func apiURL(from node: String, at path: String? = nil) throws -> URL {
        let url = try apiBase(from: node).appendingPathComponent(Beacon.P2PMatrixConfiguration.matrixClientAPIVersion)
        
        guard let path = path else {
            return url
        }
        
        return url.appendingPathComponent(path)
    }
    
    func apiBase(from node: String, at path: String? = nil) throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = node
        urlComponents.path = Beacon.P2PMatrixConfiguration.matrixClientAPIBase
        
        guard let url = urlComponents.url else {
            throw Beacon.Error.invalidURL(urlComponents.description)
        }
        
        guard let path = path else {
            return url
        }
        
        return url.appendingPathComponent(path)
    }
    
    // MARK: Types
    
    struct OngoingCall: Hashable {
        let method: HTTP.Method
        let url: URL
    }
}
