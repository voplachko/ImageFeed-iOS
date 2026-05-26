//
//  ImagesListServiceSpy.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import Foundation

final class ImagesListServiceSpy: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled: Bool = false
    var changeLikeCalled: Bool = false
    var changeLikeResult: Result<Void, Error> = .success(())
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, any Error>) -> Void) {
        changeLikeCalled = true
        completion(changeLikeResult)
    }  
}
