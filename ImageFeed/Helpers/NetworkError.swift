//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension NetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .httpStatusCode(code):
            return "NetworkError - код ошибки \(code)"
        case let .urlRequestError(error):
            return "NetworkError - urlRequestError: \(error.localizedDescription)"
        case .urlSessionError:
            return "NetworkError - urlSessionError"
        }
    }
}
