//
//  OAuth2TokenResponse.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import Foundation

struct OAuth2TokenResponse: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
