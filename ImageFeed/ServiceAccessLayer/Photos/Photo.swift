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
    let fullImageURL: String
    let isLiked: Bool
}

extension Photo {
    private static let isoWithFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoNoFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = Photo.isoWithFraction.date(from: result.createdAt)
            ?? Photo.isoNoFraction.date(from: result.createdAt)
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.fullImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
