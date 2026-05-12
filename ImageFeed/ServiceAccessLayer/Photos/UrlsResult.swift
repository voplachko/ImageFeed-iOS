//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case raw, full, regular, small, thumb
    }
}
