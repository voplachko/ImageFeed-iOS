//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 14.05.2026.
//

import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
