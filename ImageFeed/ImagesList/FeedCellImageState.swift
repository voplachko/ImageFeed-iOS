//
//  FeedCellImageState.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 15.05.2026.
//

import UIKit

enum FeedCellImageState {
    case loading
    case error
    case finished(UIImage)
}
