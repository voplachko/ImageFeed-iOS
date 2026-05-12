//
//  UserResult.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
