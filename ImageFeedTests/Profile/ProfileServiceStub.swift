//
//  ProfileServiceStub.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import Foundation

final class ProfileServiceStub: ProfileServiceProtocol {
    let profile: Profile?
    
    init(profile: Profile?) {
        self.profile = profile
    }
}

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    let avatarURL: String?
    
    init(avatarURL: String?) {
        self.avatarURL = avatarURL
    }
}

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
