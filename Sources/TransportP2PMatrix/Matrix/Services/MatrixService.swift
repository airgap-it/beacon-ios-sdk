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
    
    init(http: HTTP) {
        self.http = http
    }
    
    // MARK: Call Management
    
    func addOngoing(_ call: OngoingCall) {
        ongoingCalls.insert(call)
    }
    
    func removeOngoing(_ call: OngoingCall) {
        ongoingCalls.remove(call)
    }
    
    func cancel(for node: String) {
        for call in ongoingCalls where call.url.host == node {
            http.cancelTasks(for: call.url, and: call.method)
            ongoingCalls.remove(call)
        }
    }
    
    func cancelAll() {
        for call in ongoingCalls {
            http.cancelTasks(for: call.url, and: call.method)
        }
        ongoingCalls.removeAll()
    }
    
    func suspend(for node: String) {
        for call in ongoingCalls where call.url.host == node {
            http.suspendTasks(for: call.url, and: call.method)
        }
    }
    
    func suspendAll() {
        for call in ongoingCalls {
            http.suspendTasks(for: call.url, and: call.method)
        }
    }
    
    func resume(for node: String) {
        for call in ongoingCalls where call.url.host == node {
            http.resumeTasks(for: call.url, and: call.method)
        }
    }
    
    func resumeAll() {
        for call in ongoingCalls {
            http.resumeTasks(for: call.url, and: call.method)
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
