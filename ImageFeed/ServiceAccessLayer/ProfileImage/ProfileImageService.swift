//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 27.03.2026.
//

import Foundation

final class ProfileImageService {
    
    static let didChangeNotification = NotificationNames.profileImageDidChange
    
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    private let urlSession: URLSession = .shared
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: ErrorDomains.profileImageService, code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.avatarURL = result.profileImage.small
                completion(.success(result.profileImage.small))

                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: [UserInfoKeys.url: self.avatarURL ?? ""]
                    )

            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error)) // Прокидываем ошибку
            }
        }

        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: APIEndpoints.userURLString(username: username)) else {
            return nil
        }
        
        let headers = [
            APIHeaders.authorization: "\(APIHeaders.bearerPrefix)\(token)",
            APIHeaders.accept: APIHeaders.applicationJSON,
            APIHeaders.acceptVersion: APIHeaders.apiVersionV1
        ]
        let request = URLRequest(url: url, method: .get, headers: headers)
        return request
    }
    
    func reset() {
        task?.cancel()
        task = nil
        avatarURL = nil
    }
}
