//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: APIEndpoints.tokenURLString) else {
            print("[OAuth2Service] ❌ Failed to create URLComponents")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: APIQueryKeys.clientId, value: APIConstants.accessKey),
            URLQueryItem(name: APIQueryKeys.clientSecret, value: APIConstants.secretKey),
            URLQueryItem(name: APIQueryKeys.redirectURI, value: APIConstants.redirectURI),
            URLQueryItem(name: APIQueryKeys.code, value: code),
            URLQueryItem(name: APIQueryKeys.grantType, value: APIQueryKeys.grantTypeAuthorizationCode)
        ]
        
        guard let authTokenURL = urlComponents.url else {
            print("[OAuth2Service] ❌ Failed to create URL from URLComponents")
            return nil
        }
        
        print("[OAuth2Service] ✅ OAuth token URL: \(authTokenURL)")
        
        let request = URLRequest(url: authTokenURL, method: .post)
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
