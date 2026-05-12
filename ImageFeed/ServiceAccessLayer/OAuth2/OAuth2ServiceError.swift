//
//  OAuth2ServiceError.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

enum OAuth2ServiceError: Error {
    case invalidURLComponents
    case invalidURL
    case invalidRequest
    case httpStatusCode(Int)
    case emptyResponseData
    case decodingError(Error)
    case requestInProgress
    case requestCancelled
}
