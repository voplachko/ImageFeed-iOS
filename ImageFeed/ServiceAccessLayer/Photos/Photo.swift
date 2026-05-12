//
//  Photo.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation
internal import CoreGraphics

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension Photo {
    init(from result: PhotoResult) {
        let formatter = ISO8601DateFormatter()
        
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = formatter.date(from: result.createdAt)
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
