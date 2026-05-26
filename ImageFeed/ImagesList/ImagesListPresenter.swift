//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }

    func viewDidLoad()
    func updateTableViewAnimated()
    func numberOfRows() -> Int
    func photo(at index: Int) -> Photo
    func didSelectPhoto(at index: Int)
    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat
    func didDisplayPhoto(at index: Int)
    func didTapLike(at index: Int)
}

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

extension ImagesListService: ImagesListServiceProtocol {}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private let imagesListService: ImagesListServiceProtocol
    private(set) var photos: [Photo] = []

    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
    }

    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos

        guard oldCount != newCount else { return }
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }

    func numberOfRows() -> Int {
        photos.count
    }

    func photo(at index: Int) -> Photo {
        photos[index]
    }

    func didSelectPhoto(at index: Int) {
        let photo = photos[index]
        view?.showSingleImage(with: URL(string: photo.fullImageURL))
    }

    func heightForRow(at index: Int, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[index]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }

    func didDisplayPhoto(at index: Int) {
        guard index == photos.count - 1 else { return }
        imagesListService.fetchPhotosNextPage()
    }

    func didTapLike(at index: Int) {
        let photo = photos[index]
        view?.showBlockingProgressHUD()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.view?.dismissBlockingProgressHUD()

                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    self.view?.setLike(isLiked: self.photos[index].isLiked, at: index)

                case .failure:
                    self.view?.showLikeError()
                }
            }
        }
    }
}
