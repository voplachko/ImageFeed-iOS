//
//  HTTPMethod.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.05.2026.
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
    case head    = "HEAD"
    case options = "OPTIONS"
}

extension URLRequest {
    init(url: URL, method: HTTPMethod, headers: [String: String] = [:], body: Data? = nil) {
        self.init(url: url)
        self.httpMethod = method.rawValue
        headers.forEach { key, value in
            self.setValue(value, forHTTPHeaderField: key)
        }
        self.httpBody = body
    }
}
