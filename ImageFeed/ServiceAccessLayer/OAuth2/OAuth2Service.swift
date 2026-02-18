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
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
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
            return nil
        }
        
        var request = URLRequest(url: authTokenURL)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "InvalidRequest", code: 0)))
            return
        }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard
                let data = data,
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                if let httpResponse = response as? HTTPURLResponse {
                    print("OAuth status code: \(httpResponse.statusCode)")
                }
                
                if let data = data, let body = String(data: data, encoding: .utf8) {
                    print("OAuth token response body: \(body)")
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "InvalidResponse", code: 0)))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let tokenResponse = try decoder.decode(OAuth2TokenResponse.self, from: data)
                
                let token = tokenResponse.accessToken
                self.tokenStorage.token = token
                
                DispatchQueue.main.async {
                    completion(.success(token))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
