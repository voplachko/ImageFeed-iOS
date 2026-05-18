//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

struct UrlsResult: Codable {
    let full: String
    let thumb: String
    
    enum CodingKeys: String, CodingKey {
        case full, thumb
    }
}
