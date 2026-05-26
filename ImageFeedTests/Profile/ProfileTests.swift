//
//  ProfileTests.swift
//  ImageFeed
//
//  Created by Vsevolod Oplachko on 26.05.2026.
//

@testable import ImageFeed
import XCTest
import UIKit

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterShowsProfileDetails() {
        // given
        let profile = Profile(
            result: ProfileResult(
                username: "test_user",
                firstName: "Test",
                lastName: "User",
                bio: "Test bio"
            )
        )
        let profileService = ProfileServiceStub(profile: profile)
        let profileImageService = ProfileImageServiceStub(avatarURL: "https://test.com/avatar.jpg")
        let logoutService = ProfileLogoutServiceSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            profileLogoutService: logoutService
        )
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertEqual(viewController.name, "Test User")
        XCTAssertEqual(viewController.loginName, "@test_user")
        XCTAssertEqual(viewController.bio, "Test bio")
        XCTAssertEqual(viewController.avatarURL, "https://test.com/avatar.jpg")
    }

    func testPresenterShowsLogoutAlert() {
        // given
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profile: nil),
            profileImageService: ProfileImageServiceStub(avatarURL: nil),
            profileLogoutService: ProfileLogoutServiceSpy()
        )
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController

        // when
        presenter.didTapExitButton()

        // then
        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }

    func testPresenterCallsLogout() {
        // given
        let logoutService = ProfileLogoutServiceSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profile: nil),
            profileImageService: ProfileImageServiceStub(avatarURL: nil),
            profileLogoutService: logoutService
        )
        let viewController = ProfileViewControllerSpy()
        presenter.view = viewController

        // when
        presenter.logout()

        // then
        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(viewController.switchToSplashScreenCalled)
    }
}
