//
//  AppConstants.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.05.2026.
//

import Foundation

enum APIEndpoints {
    // Базовые
    static let apiBase = APIConstants.defaultBaseURLString
    static let siteBase = "https://unsplash.com"

    // Пути
    enum Paths {
        static let photos = "/photos"
        static let users = "/users"
        static let me = "/me"
        static let likeSuffix = "/like"
        static let oauthAuthorize = "/oauth/authorize"
        static let oauthAuthorizeNative = "/oauth/authorize/native"
        static let oauthToken = "/oauth/token"
    }

    // Готовые строки URL
    static var photosURLString: String { apiBase + Paths.photos }
    static func likePhotoURLString(photoId: String) -> String { apiBase + Paths.photos + "/\(photoId)" + Paths.likeSuffix }
    static func userURLString(username: String) -> String { apiBase + Paths.users + "/\(username)" }
    static var meURLString: String { apiBase + Paths.me }
    static var authorizeURLString: String { siteBase + Paths.oauthAuthorize }
    static var tokenURLString: String { siteBase + Paths.oauthToken }
}

enum APIHeaders {
    static let authorization = "Authorization"
    static let accept = "Accept"
    static let acceptVersion = "Accept-Version"

    static let bearerPrefix = "Bearer "
    static let applicationJSON = "application/json"
    static let apiVersionV1 = "v1"
}

enum APIQueryKeys {
    // Общие
    static let page = "page"
    static let perPage = "per_page"

    // OAuth
    static let clientId = "client_id"
    static let clientSecret = "client_secret"
    static let redirectURI = "redirect_uri"
    static let responseType = "response_type"
    static let scope = "scope"
    static let code = "code"
    static let grantType = "grant_type"

    // Значения
    static let responseTypeCode = "code"
    static let grantTypeAuthorizationCode = "authorization_code"
}

enum Defaults {
    static let photosPerPage = 10
}

enum NotificationNames {
    static let imagesListDidChange = Notification.Name("ImagesListServiceDidChange")
    static let profileImageDidChange = Notification.Name("ProfileImageProviderDidChange")
}

enum ErrorDomains {
    static let imagesListService = "ImagesListService"
    static let profileImageService = "ProfileImageService"
}

enum UserInfoKeys {
    static let url = "URL"
}
