//
//  ImagesListTests.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import XCTest
import UIKit

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsFetchPhotosNextPage() {
        //given
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        
        // when
        presenter.viewDidLoad()
        
        // then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    func testPresenterUpdatesTableView() {
        // given
        let service = ImagesListServiceSpy()
        let presenter = ImagesListPresenter(imagesListService: service)
        let viewController = ImagesListViewControllerSpy()
        presenter.view = viewController
        service.photos = [makePhoto()]
        
        // when
        presenter.updateTableViewAnimated()
        
        // then
        XCTAssertEqual(viewController.oldCount, 0)
        XCTAssertEqual(viewController.newCount, 1)
    }
    
    func testPresenterCalculatesCellHeight() {
        // given
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(size: CGSize(width: 100, height: 200))]
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.updateTableViewAnimated()
        
        // when
        let height = presenter.heightForRow(at: 0, tableViewWidth: 132)
        
        // then
        XCTAssertEqual(height, 208)
    }
    
    func testPresenterShowsSingleImage() {
        // given
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(fullImageURL: "https://test.com/full.jpg")]
        let presenter = ImagesListPresenter(imagesListService: service)
        let viewController = ImagesListViewControllerSpy()
        presenter.view = viewController
        presenter.updateTableViewAnimated()
        
        // when
        presenter.didSelectPhoto(at: 0)
        
        // then
        XCTAssertEqual(viewController.singleImageURL?.absoluteString, "https://test.com/full.jpg")
    }
    
    func testPresenterFetchesNextPageWhenLastCellDisplayed() {
        // given
        let service = ImagesListServiceSpy()
        service.photos = [makePhoto(), makePhoto(id: "2")]
        let presenter = ImagesListPresenter(imagesListService: service)
        presenter.updateTableViewAnimated()
        service.fetchPhotosNextPageCalled = false
        
        // when
        presenter.didDisplayPhoto(at: 1)
        
        // then
        XCTAssertTrue(service.fetchPhotosNextPageCalled)
    }
    
    private func makePhoto(
        id: String = "1",
        size: CGSize = CGSize(width: 100, height: 100),
        fullImageURL: String = "https://test.com/full.jpg"
    ) -> Photo {
        Photo(
            id: id,
            size: size,
            createdAt: Date(timeIntervalSince1970: 0),
            welcomeDescription: nil,
            thumbImageURL: "https://test.com/thumb.jpg",
            largeImageURL: "https://test.com/large.jpg",
            fullImageURL: fullImageURL,
            isLiked: false
        )
    }
}

