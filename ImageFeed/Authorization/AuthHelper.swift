//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest? {
        guard let url = authURL() else { return nil }
        return URLRequest(url: url)
    }

    func authURL() -> URL? {
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: APIQueryKeys.clientId, value: configuration.accessKey),
            URLQueryItem(name: APIQueryKeys.redirectURI, value: configuration.redirectURI),
            URLQueryItem(name: APIQueryKeys.responseType, value: APIQueryKeys.responseTypeCode),
            URLQueryItem(name: APIQueryKeys.scope, value: configuration.accessScope)
        ]

        return urlComponents.url
    }

    func code(from url: URL) -> String? {
        guard
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == APIEndpoints.Paths.oauthAuthorizeNative,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == APIQueryKeys.code })
        else {
            return nil
        }

        return codeItem.value
    }
}
