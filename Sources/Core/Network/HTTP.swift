//
//  HTTP.swift
//  CoinKit
//
//  Created by Mike Godenzi on 03.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class HTTP {
    private let session: URLSession
    
    private var ongoingTasks: [String: Set<URLSessionTask>] = [:]
    private let ongoingTasksQueue: DispatchQueue = .init(
        label: "it.airgap.beacon-sdk.HTTP.ongoingTasks",
        qos: .default,
        attributes: [],
        target: .global(qos: .default)
    )
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: Methods
    
    public func get<R: Codable, E: Codable & Swift.Error>(
        at url: URL,
        headers: [Header] = [],
        parameters: [(String, String?)] = [],
        throwing errorType: E.Type,
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        do {
            var request = try createRequest(for: .get, at: url, parameters: parameters)
            request.set(headers: headers)
            send(request: request, throwing: errorType, completion: completion)
        } catch {
            completion(.failure(Error(error)))
        }
    }
    
    public func post<R: Codable, B: Codable, E: Codable & Swift.Error>(
        at url: URL,
        body: B,
        headers: [Header] = [],
        parameters: [(String, String?)] = [],
        throwing errorType: E.Type,
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        do {
            var request = try createRequest(for: .post, at: url, parameters: parameters)
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.set(headers: headers + [.contentType("application/json")])
            send(request: request, throwing: errorType, completion: completion)
        } catch {
            completion(.failure(Error(error)))
        }
    }
    
    public func put<R: Codable, B: Codable, E: Codable & Swift.Error>(
        at url: URL,
        body: B,
        headers: [Header] = [],
        parameters: [(String, String?)] = [],
        throwing errorType: E.Type,
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        do {
            var request = try createRequest(for: .put, at: url, parameters: parameters)
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.set(headers: headers + [.contentType("application/json")])
            send(request: request, throwing: errorType, completion: completion)
        } catch {
            completion(.failure(Error(error)))
        }
    }
    
    // MARK: Task Management
    
    public func cancelTasks(for url: URL, and method: HTTP.Method) {
        ongoingTasksQueue.async {
            guard let tasks = self.ongoingTasks.get(for: url, and: method) else { return }
            
            tasks.forEach { $0.cancel() }
            self.ongoingTasks.removeTasks(for: url, and: method)
        }
    }
    
    public func cancelAllTasks() {
        ongoingTasksQueue.async {
            self.ongoingTasks.values.flatMap { $0 }.forEach { $0.cancel() }
            self.ongoingTasks.removeAll()
        }
    }
    
    public func suspendTasks(for url: URL, and method: HTTP.Method) {
        ongoingTasksQueue.async {
            guard let tasks = self.ongoingTasks.get(for: url, and: method) else { return }
            
            tasks.forEach { $0.suspend() }
        }
    }
    
    public func suspendAllTasks() {
        ongoingTasksQueue.async {
            self.ongoingTasks.values.flatMap { $0 }.forEach { $0.suspend() }
        }
    }
    
    public func resumeTasks(for url: URL, and method: HTTP.Method) {
        ongoingTasksQueue.async {
            guard let tasks = self.ongoingTasks.get(for: url, and: method) else { return }
            
            tasks.forEach { $0.resume() }
        }
    }
    
    public func resumeAllTasks() {
        ongoingTasksQueue.async {
            self.ongoingTasks.values.flatMap { $0 }.forEach { $0.resume() }
        }
    }
    
    // MARK: Call Handlers
    
    private func createRequest(for method: Method, at url: URL, parameters: [(String, String?)] = []) throws -> URLRequest {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        if !parameters.isEmpty {
            urlComponents?.queryItems = parameters.map { (name, value) in URLQueryItem(name: name, value: value) }
        }
        
        guard let url = urlComponents?.url else {
            throw Error.invalidURL(url)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.set(header: .accept("application/json"))
        
        return request
    }
    
    private func send<R: Codable, E: Codable & Swift.Error>(
        request: URLRequest,
        throwing errorType: E.Type,
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        var dataTask: URLSessionTask!
        dataTask = session.dataTask(with: request) { [weak self] result in
            guard let selfStrong = self else {
                completion(.failure(Beacon.Error.unknown()))
                return
            }
            
            selfStrong.ongoingTasksQueue.async {
                selfStrong.ongoingTasks.remove(for: request, element: dataTask)
            }
                
            switch result {
            case let .success((data, _)):
                completion(selfStrong.parse(data: data))
            case let .failure(error):
                switch error {
                case let Error.http(data, _):
                    guard let parsedError: E = try? selfStrong.parse(data: data).get() else {
                        fallthrough
                    }
                    completion(.failure(parsedError))
                default:
                    completion(.failure(Error(error)))
                }
            }
        }
        
        ongoingTasksQueue.async {
            self.ongoingTasks.append(for: request, element: dataTask)
        }
        
        dataTask.resume()
    }
    
    private func parse<R: Codable>(data: Data) -> Result<R, Swift.Error> {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        do {
            let result = try decoder.decode(R.self, from: data)
            return .success(result)
        } catch {
            return .failure(Error(error))
        }
    }
    
    // MARK: Types
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    public enum Header {
        case authorization(String)
        case contentType(String)
        case accept(String)
        
        public static func bearer(token: String) -> Header {
            .authorization("Bearer \(token)")
        }
        
        public var tuple: (String, String) {
            switch self {
            case let .authorization(value):
                return ("Authorization", value)
            case let .contentType(value):
                return ("Content-Type", value)
            case let .accept(value):
                return ("Accept", value)
            }
        }
    }
    
    enum Error: Swift.Error {
        case invalidURL(URL)
        case http(Data, Int)
        
        case other(Swift.Error)
        
        init(_ error: Swift.Error) {
            guard let httpError = error as? Error else {
                self = .other(error)
                return
            }
            self = httpError
        }
    }
}

// MARK: Extensions

private extension URLSession {
    
    func dataTask(with request: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> ()) -> URLSessionDataTask {
        return dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(error ?? Beacon.Error.unknown()))
                return
            }
            guard (200..<300).contains(response.statusCode) else {
                completion(.failure(HTTP.Error.http(data, response.statusCode)))
                return
            }
            completion(.success((data, response)))
        }
    }
}

private extension URLRequest {
    
    mutating func set(header: HTTP.Header) {
        let tuple = header.tuple
        setValue(tuple.1, forHTTPHeaderField: tuple.0)
    }
    
    mutating func set(headers: [HTTP.Header]) {
        headers.forEach { set(header: $0) }
    }
}

private extension Dictionary where Key == String, Value == Set<URLSessionTask> {
    func get(for url: URL, and method: HTTP.Method) -> Value? {
        get(for: url, andMethod: method.rawValue)
    }
    
    func get(for url: URL, andMethod method: String) -> Value? {
        self[key(from: url, andMethod: method)]
    }
    
    mutating func append(for request: URLRequest, element: URLSessionTask) {
        guard let key = key(from: request) else { return }
        
        append(forKey: key, element: element)
    }
    
    mutating func remove(for request: URLRequest, element: URLSessionTask) {
        guard let key = key(from: request) else { return }
        
        let difference = (self[key] ?? []).subtracting([element])
        
        if difference.isEmpty {
            self.removeValue(forKey: key)
        } else {
            self[key] = difference
        }
    }
    
    mutating func removeTasks(for url: URL, and method: HTTP.Method) {
        removeTasks(for: url, andMethod: method.rawValue)
    }
    
    mutating func removeTasks(for url: URL, andMethod method: String) {
        removeValue(forKey: key(from: url, andMethod: method))
    }
    
    private func key(from request: URLRequest) -> String? {
        guard let url = request.url else { return nil }
        guard let method = request.httpMethod else { return nil }
        
        return key(from: url, andMethod: method)
    }
    
    private func key(from url: URL, andMethod method: String) -> String {
        "\(method.lowercased()):\(url.absoluteString)"
    }
}
