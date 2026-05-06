//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import Foundation

enum OAuth2ServiceError: Error {
    case invalidURLComponents
    case invalidURL
    case invalidRequest
    case httpStatusCode(Int)
    case emptyResponseData
    case decodingError(Error)
    case requestInProgress
    case requestCancelled
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("[OAuth2Service] ❌ Failed to create URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: APIConstants.accessKey),
            URLQueryItem(name: "client_secret", value: APIConstants.secretKey),
            URLQueryItem(name: "redirect_uri", value: APIConstants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenURL = urlComponents.url else {
            print("[OAuth2Service] ❌ Failed to create URL from URLComponents")
            return nil
        }
        
        print("[OAuth2Service] ✅ OAuth token URL: \(authTokenURL)")
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if let runningTask = task {
            if lastCode != code {
                runningTask.cancel()
            } else {
                completion(.failure(OAuth2ServiceError.requestInProgress))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(OAuth2ServiceError.requestInProgress))
                return
            }
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] ❌ Invalid request (makeOAuthTokenRequest returned nil)")
            completion(.failure(OAuth2ServiceError.invalidRequest))
            return
        }
        
        var currentTask: URLSessionTask?
        
        currentTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuth2TokenResponse, Error>) in
            guard let self else { return }
            guard self.task === currentTask else { return }
            
            defer {
                self.task = nil
                self.lastCode = nil
            }
            
            switch result {
            case let .success(tokenResponse):
                let token = tokenResponse.accessToken
                self.tokenStorage.token = token
                completion(.success(token))
                
            case let .failure(error):
                print("[OAuth2Service]: \(error)")
                
                if let networkError = error as? NetworkError,
                   case let .urlRequestError(underlyingError) = networkError,
                   (underlyingError as NSError).code == NSURLErrorCancelled
                {
                    completion(.failure(OAuth2ServiceError.requestCancelled))
                    return
                }
                
                completion(.failure(error))
            }
        }
        
        self.task = currentTask
        currentTask?.resume()
    }
}
