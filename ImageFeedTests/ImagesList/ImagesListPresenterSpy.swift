//
//  ImagesListPresenterSpy.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import UIKit

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateTableViewAnimated() {}
    
    func numberOfRows() -> Int {
        photos.count
    }
    
    func photo(at index: Int) -> ImageFeed.Photo {
        photos[index]
    }
    
    func didSelectPhoto(at index: Int) {}
    
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        0
    }
    
    func didDisplayPhoto(at index: Int) {}
    
    func didTapLike(at index: Int) {}
}
