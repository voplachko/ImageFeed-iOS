//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String

    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        authURLString: String,
        defaultBaseURLString: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.authURLString = authURLString
        self.defaultBaseURLString = defaultBaseURLString
    }

    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: APIConstants.accessKey,
            secretKey: APIConstants.secretKey,
            redirectURI: APIConstants.redirectURI,
            accessScope: APIConstants.accessScope,
            authURLString: APIEndpoints.authorizeURLString,
            defaultBaseURLString: APIConstants.defaultBaseURLString
        )
    }
}
