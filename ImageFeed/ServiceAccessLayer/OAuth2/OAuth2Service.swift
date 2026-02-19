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
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage()
    
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service] ❌ Invalid request (makeOAuthTokenRequest returned nil)")
            DispatchQueue.main.async {
                completion(.failure(OAuth2ServiceError.invalidRequest))
            }
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            if let error {
                print("[OAuth2Service] ❌ Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[OAuth2Service] ❌ No HTTPURLResponse")
                DispatchQueue.main.async {
                    completion(.failure(OAuth2ServiceError.emptyResponseData))
                }
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard 200..<300 ~= statusCode else {
                print("[OAuth2Service] ❌ HTTP status code: \(statusCode)")
                
                if let data, let body = String(data: data, encoding: .utf8) {
                    print("[OAuth2Service] ❌ Response body: \(body)")
                } else {
                    print("[OAuth2Service] ❌ Response body is empty or not utf8")
                }
                
                DispatchQueue.main.async {
                    completion(.failure(OAuth2ServiceError.httpStatusCode(statusCode)))
                }
                return
            }
            
            guard let data else {
                print("[OAuth2Service] ❌ Empty data with success status code: \(statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(OAuth2ServiceError.emptyResponseData))
                }
                return
            }
            
            do {
                let tokenResponse = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
                let token = tokenResponse.accessToken
                self?.tokenStorage.token = token
                
                DispatchQueue.main.async {
                    completion(.success(token))
                }
            } catch {
                print("[OAuth2Service] ❌ Decoding error: \(error)")
                if let body = String(data: data, encoding: .utf8) {
                    print("[OAuth2Service] ❌ Raw response for debugging: \(body)")
                }
                DispatchQueue.main.async {
                    completion(.failure(OAuth2ServiceError.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
}
