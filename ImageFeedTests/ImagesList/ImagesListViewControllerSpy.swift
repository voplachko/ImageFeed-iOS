//
//  ImagesListViewControllerSpy.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import UIKit

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var oldCount: Int?
    var newCount: Int?
    var singleImageURL: URL?
    var showBlockingProgressHUDCalled = false
    var dismissBlockingProgressHUDCalled = false
    var isLiked: Bool?
    var likedIndex: Int?
    var showLikeErrorCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        self.oldCount = oldCount
        self.newCount = newCount
    }
    
    func showSingleImage(with url: URL?) {
        singleImageURL = url
    }
    
    func showBlockingProgressHUD() {
        showBlockingProgressHUDCalled = true
    }
    
    func dismissBlockingProgressHUD() {
        dismissBlockingProgressHUDCalled = true
    }
    
    func setLike(isLiked: Bool, at index: Int) {
        self.isLiked = isLiked
        likedIndex = index
    }
    
    func showLikeError() {
        showLikeErrorCalled = true
    }
}
