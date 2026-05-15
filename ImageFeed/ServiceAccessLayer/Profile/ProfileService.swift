//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 24.02.2026.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(result: ProfileResult) {
        username = result.username
        loginName = "@\(result.username)"
        
        let parts = [result.firstName, result.lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        name = parts.joined(separator: " ")
        bio = result.bio
    }
}

final class ProfileService {
    static let shared = ProfileService()

    private let urlSession: URLSession
    private var task: URLSessionTask?
    private(set) var profile: Profile?

    private init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func fetchProfile(_ token: String,
                      completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)

        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService] ❌ Failed to create URLRequest")
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        var currentTask: URLSessionTask?

        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            guard self.task === currentTask else { return } 

            switch result {
            case let .success(profileResult):
                let profile = Profile(result: profileResult)
                self.profile = profile
                completion(.success(profile))

            case let .failure(error):
                print("[ProfileService]: \(error)")

                if let networkError = error as? NetworkError,
                   case let .urlRequestError(underlyingError) = networkError,
                   (underlyingError as NSError).code == NSURLErrorCancelled
                {
                    return
                }

                completion(.failure(error))
            }
        }

        self.task = currentTask
        currentTask?.resume()
    }
    
    func reset() {
        task?.cancel()
        task = nil
        profile = nil
    }
}

private extension ProfileService {
    func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        
        return request
    }
}
