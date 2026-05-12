//
//  ProfileServiceError.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
    case invalidResponse
    case httpStatusCode(Int)
    case emptyData
}
