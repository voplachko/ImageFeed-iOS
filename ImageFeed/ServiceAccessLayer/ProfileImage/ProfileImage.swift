//
//  ProfileImage.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}
