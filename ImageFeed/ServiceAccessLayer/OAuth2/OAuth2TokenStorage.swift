//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 18.02.2026.
//

import Foundation
import SwiftKeychainWrapper

public final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    public init() {}
    
    private let tokenKey = "token"

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
