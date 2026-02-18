//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import Foundation

final class OAuth2TokenStorage {
    private enum Keys {
        static let token = "oauth_token"
    }

    var token: String? {
        get { UserDefaults.standard.string(forKey: Keys.token) }
        set { UserDefaults.standard.setValue(newValue, forKey: Keys.token) }
    }
}
