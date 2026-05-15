//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 12.05.2026.
//

import Foundation

final class ImagesListService {
    
    // MARK: - Public Properties
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    static let shared = ImagesListService()
    private init() {}
    
    private(set) var photos: [Photo] = []
    
    
    // MARK: - Private Properties
    
    private var currentTask: URLSessionTask?
    private var lastLoadedPage: Int?
    private let urlSession: URLSession = .shared
    
    // MARK: - Public Methods
    
    func fetchPhotosNextPage() {
        guard currentTask == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else { return }
        
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    self.currentTask = nil
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.currentTask = nil
                    print("[ImagesListService]: \(error.localizedDescription)")
                }
            }
        }
        
        currentTask?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ImagesListService", code: -1)))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self else { return }

            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]

                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            fullImageURL: photo.fullImageURL,
                            isLiked: !photo.isLiked
                        )

                        self.photos[index] = newPhoto
                    }

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )

                    completion(.success(()))
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Methods
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        
        var components = URLComponents(string: "https://api.unsplash.com/photos")
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func reset() {
        currentTask?.cancel()
        currentTask = nil
        lastLoadedPage = nil
        photos = []
    }
}
