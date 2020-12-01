//
//  HTTP.swift
//  CoinKit
//
//  Created by Mike Godenzi on 03.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

class HTTP {
    
    let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: Methods
    
    func get<R: Codable>(
        at path: String,
        headers: [Header] = [],
        parameters: [(String, String?)] = [],
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        do {
            var request = try createRequest(for: .get, at: path, parameters: parameters)
            request.set(headers: headers)
            send(request: request, completion: completion)
        } catch {
            completion(.failure(Error(error)))
        }
    }
    
    func post<R: Codable, B: Codable>(
        at path: String,
        body: B,
        headers: [Header] = [],
        parameters: [(String, String?)] = [],
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        do {
            var request = try createRequest(for: .post, at: path, parameters: parameters)
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.set(headers: headers + [.contentType("application/json")])
            send(request: request, completion: completion)
        } catch {
            completion(.failure(Error(error)))
        }
    }
    
    func put<R: Codable, B: Codable>(
        at path: String,
        body: B,
        headers: [Header] = [],
        parameters: [(String, String?)] = [],
        completion: @escaping (Result<R, Swift.Error>) -> ()
    ) {
        do {
            var request = try createRequest(for: .put, at: path, parameters: parameters)
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
            request.set(headers: headers + [.contentType("application/json")])
            send(request: request, completion: completion)
        } catch {
            completion(.failure(Error(error)))
        }
    }
    
    // MARK: Call Handlers
    
    private func createRequest(for method: Method, at path: String, parameters: [(String, String?)] = []) throws -> URLRequest {
        let urlPath = baseURL.appendingPathComponent(path)
        var urlComponents = URLComponents(url: urlPath, resolvingAgainstBaseURL: false)
        
        if !parameters.isEmpty {
            urlComponents?.queryItems = parameters.map { (name, value) in URLQueryItem(name: name, value: value) }
        }
        
        guard let url = urlComponents?.url else {
            throw Error.invalidURL(urlPath)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.set(header: .accept("application/json"))
        
        return request
    }
    
    private func send<R: Codable>(request: URLRequest, completion: @escaping (Result<R, Swift.Error>) -> ()) {
        let dataTask = session.dataTask(with: request) { [weak self] result in
            guard let selfStrong = self else {
                completion(.failure(Beacon.Error.unknown))
                return
            }
            switch result {
            case let .success((data, _)):
                completion(selfStrong.parse(data: data))
            case let .failure(error):
                completion(.failure(Error(error)))
            }
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
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
    }
    
    enum Header {
        case authorization(String)
        case contentType(String)
        case accept(String)
        
        static func bearer(token: String) -> Header {
            .authorization("Bearer \(token)")
        }
        
        var tuple: (String, String) {
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
        case http(Int)
        
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
                completion(.failure(error ?? Beacon.Error.unknown))
                return
            }
            guard (200..<300).contains(response.statusCode) else {
                completion(.failure(HTTP.Error.http(response.statusCode)))
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
