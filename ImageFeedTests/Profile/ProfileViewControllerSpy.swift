//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var name: String?
    var loginName: String?
    var bio: String?
    var avatarURL: String?
    var showLogoutAlertCalled = false
    var switchToSplashScreenCalled = false

    func showProfileDetails(name: String, loginName: String, bio: String) {
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }

    func updateAvatar(with url: String?) {
        avatarURL = url
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }

    func switchToSplashScreen() {
        switchToSplashScreenCalled = true
    }
}
